import Foundation
import Supabase

final class PostsController {

    private let client = SupabaseConfig.client

    func addPost(_ post: Post) async throws -> Post {

        let session = try await client.auth.session

        let payload = PostInsertPayload (
            user_id: session.user.id,
            name: post.name,
            deadline: post.tasks.map(\.deadline).max() ?? Date(),
            platform: post.platform,
            reminder: post.reminder
        )

        let postDB: PostDB = try await client.database
            .from("posts")
            .insert(payload)
            .select()
            .execute()
            .value

        let taskPayload = post.tasks.map {
            TaskDB(
                id: UUID(),
                post_id: postDB.id,
                name: $0.name,
                deadline: $0.deadline,
                isCompleted: $0.isCompleted
            )
        }

        let insertedTasks: [TaskDB] = try await client.database
            .from("tasks")
            .insert(taskPayload)
            .select()
            .execute()
            .value

        return mapToPost(postDB, insertedTasks)
    }


    func fetchPosts() async throws -> [Post] {

        let session = try await client.auth.session

        let posts: [PostDB] = try await client.database
            .from("posts")
            .select()
            .eq("user_id", value: session.user.id)
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
                tasks.filter { $0.post_id == post.id }
            )
        }
    }

    private func mapToPost(_ post: PostDB, _ tasks: [TaskDB]) -> Post {
        Post(
            id: post.id,
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
            reminder: []
        )
    }
}
