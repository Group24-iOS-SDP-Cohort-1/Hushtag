import Foundation
import Supabase

final class PostsController {
    
    private let client = SupabaseConfig.client
    
    func addPost(_ post: Post) async throws -> Post {
            
            let session = try await client.auth.session
            
            let payload = PostInsertPayload (
                user_id: session.user.id,
                name: post.name,
                deadline: post.deadline,
                platform: post.platform.map(\.rawValue),
                reminder: post.reminder ?? []
            )
            
            let postDB: PostDB = try await client.database
                .from("posts")
                .insert(payload)
                .select()
                .single()
                .execute()
                .value
            
            var insertedTasks: [TaskDB] = []
            
            // ADDED: Check if tasks exist before inserting
            if !post.tasks.isEmpty {
                let taskPayload = post.tasks.map {
                    TaskDB(
                        id: UUID(),
                        post_id: postDB.post_id,
                        name: $0.name,
                        deadline: $0.deadline,
                        isCompleted: $0.isCompleted
                    )
                }
                
                insertedTasks = try await client.database
                    .from("sub_tasks")
                    .insert(taskPayload)
                    .select()
                    .execute()
                    .value
            }
            
            return mapToPost(postDB, insertedTasks)
        }
    
    func fetchPosts() async throws -> [Post] {
        
        let session = try await client.auth.session
        print("FETCH UID:", session.user.id)
        
        let posts: [PostDB] = try await client.database
            .from("posts")
            .select()
            .eq("user_id", value: session.user.id)
            .order("deadline", ascending: true)
            .execute()
            .value
        
        let tasks: [TaskDB] = try await client.database
            .from("sub_tasks")
            .select()
            .execute()
            .value
        
        return posts.map { post in
            mapToPost(
                post,
                tasks.filter { $0.post_id == post.post_id }
            )
        }
    }
    
    func deletePost(postId: UUID) async throws {
        let session = try await client.auth.session
        
        try await client.database
            .from("posts")
            .delete()
            .eq("post_id", value: postId)
            .eq("user_id", value: session.user.id)
            .execute()
    }
    
    
    func updatePost(_ post: Post) async throws -> Post {
            
            let session = try await client.auth.session
            
            let payload = PostInsertPayload (
                user_id: session.user.id,
                name: post.name,
                deadline: post.deadline,
                platform: post.platform.map(\.rawValue),
                reminder: post.reminder ?? []
            )
            
            let updatedPost: PostDB = try await client.database
                .from("posts")
                .update(payload)
                .eq("post_id", value: post.id ?? UUID())
                .select()
                .single()
                .execute()
                .value
            
            try await client.database
                .from("sub_tasks")
                .delete()
                .eq("post_id", value: post.id ?? UUID())
                .execute()
            
            var updatedTasks: [TaskDB] = []
            
            // ADDED: Check if tasks exist before inserting new ones
            if !post.tasks.isEmpty {
                let taskPayloads = post.tasks.map {
                    TaskDB(
                        id: UUID(),
                        post_id: post.id ?? UUID(),
                        name: $0.name,
                        deadline: $0.deadline,
                        isCompleted: $0.isCompleted
                    )
                }
                
                updatedTasks = try await client.database
                    .from("sub_tasks")
                    .insert(taskPayloads)
                    .select()
                    .execute()
                    .value
            }
            
            return mapToPost(updatedPost, updatedTasks)
        }
    
    func updateTaskCompletion(
        taskId: UUID,
        isCompleted: Bool
    ) async throws {
        
        try await client.database
            .from("sub_tasks")
            .update(["isCompleted": isCompleted])
            .eq("id", value: taskId)
            .execute()
    }
    
    private func mapToPost(_ post: PostDB, _ tasks: [TaskDB]) -> Post {
        Post(
            id: post.post_id,
            name: post.name,
            platform: post.platform,
            tasks: tasks.map {
                Tasks(
                    id: $0.id,
                    name: $0.name,
                    deadline: $0.deadline,
                    isCompleted: $0.isCompleted
                )
            },
            reminder: post.reminder,
            deadline: post.deadline
        )
    }
}
