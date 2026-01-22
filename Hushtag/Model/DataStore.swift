import Foundation

class DataStore {

    private var deals: [Deal] = []
    private var posts: [Post] = []

    static let shared = DataStore()

    private init() {
        loadSampleData()
    }

    func getDeals() -> [Deal] {
        deals
    }

    func getPosts() -> [Post] {
        posts
    }

    func saveDeal(_ deal: Deal) {
        deals.append(deal)
    }

    func savePost(_ post: Post) {
        posts.append(post)
    }

    func updatePost(_ updatedPost: Post) {
        if let index = posts.firstIndex(where: { $0.name == updatedPost.name }) {
            posts[index] = updatedPost
        }
    }

    func updateDeal(_ updatedDeal: Deal) {
        if let index = deals.firstIndex(where: { $0.name == updatedDeal.name }) {
            deals[index] = updatedDeal
        }
    }

    func scheduleItems(on date: Date) -> [ScheduleItem] {
        let calendar = Calendar.current

        let postItems = posts
            .filter { post in
                post.tasks?.contains {
                    calendar.isDate($0.deadline, inSameDayAs: date)
                } ?? false
            }
            .map { ScheduleItem.post($0) }

        let dealItems = deals
            .filter { deal in
                deal.deliverable.contains {
                    calendar.isDate($0.deadline, inSameDayAs: date)
                }
            }
            .map { ScheduleItem.deal($0) }

        return (postItems + dealItems)
            .sorted { ($0.date() ?? .distantFuture) < ($1.date() ?? .distantFuture) }
    }

    func completedScheduleItems(on date: Date) -> [ScheduleItem] {
        scheduleItems(on: date).filter { $0.isCompleted }
    }

    func loadSampleData() {

        let calendar = Calendar.current

        func makeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
            calendar.date(from: DateComponents(
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute
            ))!
        }

        let sampleTasks: [Task] = [
            Task(
                name: "Everyday Glam Makeup Reel",
                deadline: makeDate(year: 2026, month: 1, day: 18, hour: 10, minute: 0),
                isCompleted: false
            ),
            Task(
                name: "Unboxing New Cosmetic Products",
                deadline: makeDate(year: 2026, month: 1, day: 19, hour: 11, minute: 0),
                isCompleted: true
            ),
            Task(
                name: "Recreate Model Look",
                deadline: makeDate(year: 2026, month: 1, day: 13, hour: 9, minute: 30),
                isCompleted: false
            ),
            Task(
                name: "Edit & Schedule Instagram Post",
                deadline: makeDate(year: 2026, month: 1, day: 14, hour: 15, minute: 0),
                isCompleted: true
            ),
            Task(
                name: "Research Upcoming Beauty Trends",
                deadline: makeDate(year: 2026, month: 1, day: 22, hour: 10, minute: 0),
                isCompleted: false
            )
        ]

        let sampleDeals: [Deal] = [
            Deal(
                name: "NARS Cosmetics",
                deliverable: [
                    Deliverable(
                        name: "IG Concept Draft",
                        deadline: makeDate(year: 2026, month: 1, day: 1, hour: 10, minute: 30),
                        isCompleted: true
                    ),
                    Deliverable(
                        name: "Final IG Carousel",
                        deadline: makeDate(year: 2026, month: 1, day: 20, hour: 16, minute: 0),
                        isCompleted: false
                    )
                ],
                platform: ["instagram"],
                phone: "9028399567",
                email: "nars@collabs.com",
                description: "Blush launch campaign with carousel post.",
                payment: 5000,
                selectedIdeaIndex: "i1"
            ),
            Deal(
                name: "H&M Lifestyle",
                deliverable: [
                    Deliverable(
                        name: "Winter Reel Ideation",
                        deadline: makeDate(year: 2026, month: 03, day: 19, hour: 12, minute: 00),
                        isCompleted: true
                    ),
                    Deliverable(
                        name: "Streetwear Reel Shoot",
                        deadline: makeDate(year: 2026, month: 03, day: 21, hour: 14, minute: 30),
                        isCompleted: true
                    )
                ],
                platform: ["Instagram"],
                phone: "9028388567",
                email: "lifestyle@hm.com",
                description: "Winter streetwear reel series.",
                payment: 9000,
                selectedIdeaIndex: "i2"
            ),
            Deal(
                name: "Lakmé India",
                deliverable: [
                    Deliverable(
                        name: "Product Teaser Shoot",
                        deadline: makeDate(year: 2026, month: 06, day: 11, hour: 11, minute: 00),
                        isCompleted: false
                    ),
                    Deliverable(
                        name: "Brand Reel Editing",
                        deadline: makeDate(year: 2026, month: 06, day: 13, hour: 11, minute: 30),
                        isCompleted: false
                    ),
                    Deliverable(
                        name: "Final Campaign Upload",
                        deadline: makeDate(year: 2026, month: 06, day: 15, hour: 12, minute: 30),
                        isCompleted: false
                    )
                ],
                platform: ["YouTube"],
                phone: "9123456701",
                email: "brand@lakmeindia.com",
                description: "Matte foundation launch campaign.",
                payment: 9500,
                selectedIdeaIndex: "i5"
            ),
            Deal(
                name: "Nykaa Beauty",
                deliverable: [
                    Deliverable(
                        name: "Lipstick Tutorial Video",
                        deadline: makeDate(year: 2026, month: 04, day: 11, hour: 17, minute: 00),
                        isCompleted: true
                    ),
                    Deliverable(
                        name: "Everyday Lipstick Look Reel",
                        deadline: makeDate(year: 2026, month: 04, day: 14, hour: 16, minute: 30),
                        isCompleted: false
                    )
                ],
                platform: ["YouTube"],
                phone: "9011388567",
                email: "collabs@nykaa.com",
                description: "Tutorial featuring newly launched lipstick shades.",
                payment: 4000,
                selectedIdeaIndex: "i3"
            ),
            Deal(
                name: "Myntra",
                deliverable: [
                    Deliverable(
                        name: "Try-On Reel Shoot",
                        deadline: makeDate(year: 2026, month: 02, day: 21, hour: 17, minute: 00),
                        isCompleted: false
                    ),
                    Deliverable(
                        name: "Final Reel Upload",
                        deadline: makeDate(year: 2026, month: 02, day: 24, hour: 10, minute: 30),
                        isCompleted: false
                    )
                ],
                platform: ["YouTube"],
                phone: "9123456701",
                email: "campaign@myntra.com",
                description: "Winter jacket try-on haul.",
                payment: 6500,
                selectedIdeaIndex: "i4"
            )
            
        ]

        let samplePosts: [Post] = [
            Post(
                name: "IG Reel – Nighttime Skincare Reset",
                platform: ["instagram"],
                tasks: [sampleTasks[0], sampleTasks[3]],
                reminder: ["1 hour before", "15 minutes before"]
            )
        ]

        self.deals = sampleDeals
        self.posts = samplePosts
    }
}
