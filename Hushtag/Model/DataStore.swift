//
//  DataStore.swift
//  Hushtag
//
//  Created by SDC-USER on 19/11/25.
//

import Foundation

class DataStore {
    // arrays for storing
    private var ideas: [Idea] = []
    private var video: [Videos] = []
    private var tasks: [Tasks] = []
    private var deals: [Deals] = []
    private var posts: [Posts] = []
    private var youtubeAnalysis: [Analysis] = []
    private var instagramAnalysis: [Analysis] = []
    private var facebookAnalysis: [Analysis] = []
    private var niche : [String] = ["beauty", "fashion", "lifestyle", "sports", "travel", "food", "tech", "books", "movies", "music"]
    
    // initialiser
    init() {
        ideaData()
        videoData()
        tasksData()
        dealsData()
        postsData()
        analysisData()
    }
    
    // getter functions
    func getIdeas() -> [Idea] {
        return ideas
    }

    func getVideos() -> [Videos] {
        return video
    }
    
    func getTasks() -> [Tasks] {
        return tasks
    }
    func getDeals() -> [Deals] {
        return deals
    }
    
    func getPosts() -> [Posts] {
        return posts
    }
    
    func getYoutubeAnalysis() -> [Analysis] {
        return youtubeAnalysis
    }
    
    func getInstagramAnalysis() -> [Analysis] {
        return instagramAnalysis
    }
    
    func getFacebookAnalysis() -> [Analysis] {
        return facebookAnalysis
    }
    
    // stored values
    func ideaData() {
        let sampleData: [Idea] = [
            Idea(
                trending: "fashion",
                title: "Unlock Your Style: Must-Known Fashion Hacks!",
                description: "Looking to level up your wardrobe without breaking the bank? In this video, we’re sharing 10 game-changing fashion style tips.",
                script: "",
                hashtag: ["beauty", "style"],
                videos: video,
                liked: false,
                tag: "",
                thumbnail: ""
            ),
            Idea(
                trending: "lifestyle",
                title: "Morning Routine, Coffee Run, Studying | Vlog",
                description: "Make a video showing your productive morning routine",
                script: "",
                hashtag: ["tips", "coffee"],
                videos: video,
                liked: false,
                tag: "",
                thumbnail: ""
            ),
            Idea(
                trending: "fashion",
                title: "Unlock Your Style: Must-Known Fashion Hacks!",
                description: "Looking to level up your wardrobe without breaking the bank? In this video, we’re sharing 10 game-changing fashion hacks that’ll instantly upgrade your style! From DIY outfit tricks to smart accessorizing tips, these ideas will help you look put-together and trendy on any budget.",
                script: "",
                hashtag: ["beauty", "style"],
                videos: [],
                liked: false,
                tag: "",
                thumbnail: ""
            ),
            Idea(
                trending: "fashion",
                title: "Unlock Your Style: Must-Known Fashion Hacks!",
                description: "Looking to level up your wardrobe without breaking the bank? In this video, we’re sharing 10 game-changing fashion style tips.",
                script: "",
                hashtag: ["beauty", "style"],
                videos: [],
                liked: false,
                tag: "",
                thumbnail: ""
            )
        ]
        
        self.ideas = sampleData
    }
    
    func videoData() {
        let sampleVideos: [Videos] = [
            Videos(
                url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                videoTitle: "5-Minute Morning Makeup Routine",
                views: "3.6M"
            ),
            Videos(
                url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                videoTitle: "5 Tips For Better Make Up",
                views: "2.3M"
            ),
            Videos(
                url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                videoTitle: "Buying everything in one colour",
                views: "1.4M"
            )
        ]
        self.video = sampleVideos
    }
    
    func tasksData() {
        let sampleTasks: [Tasks] = [
            Tasks(
                name: "Everyday Glam",
                startDate: DateFormat(day: "Monday", date: Date(), time: DateComponents()),
                endDate: DateFormat(day: "Friday", date: Date(), time: DateComponents()),
                description: "Create a soft, everyday glam look that enhances your natural features and feels effortless.",
                reminder: ["1 hour before", "1 day before"]
            ),
            Tasks(
                name: "Unboxing Cosmetic Products",
                startDate: DateFormat(day: "Monday", date: Date(), time: DateComponents()),
                endDate: DateFormat(day: "Friday", date: Date(), time: DateComponents()),
                description: "Unbox and review new cosmetic products — capture photos/videos and schedule the post for publishing.",
                reminder: ["1 hour before"]
            ),
            Tasks(
                name: "Get the look of a model",
                startDate: DateFormat(day: "Monday", date: Date(), time: DateComponents()),
                endDate: DateFormat(day: "Friday", date: Date(), time: DateComponents()),
                description: "Showcase the full transformation with featured products and styling details.",
                reminder: ["15 mins before"]
            )
        ]
        self.tasks = sampleTasks
    }
    
    func dealsData() {
        let sampleDeals: [Deals] = [
            Deals(
                name: "NARS Cosmetics",
                deliverable: [
                    Deliverable(
                        name: "Draft concept for IG Post #1",
                        deadline: DateFormat(day: "Monday", date: Date(), time: DateComponents(hour: 10, minute: 30)
                        )
                    ),
                    Deliverable(
                        name: "Final IG Carousel Post",
                        deadline: DateFormat(day: "Wednesday", date: Date(), time: DateComponents(hour: 15, minute: 00)
                        )
                    )
                ],
                platform: [.instagram, .youtube],
                phone: "9028399567",
                email: "nars.cosmetics@gmail.com",
                description: "Promotional campaign for new blush collection.",
                payment: 5000,
                selectedIdea: ideas
            ),
            Deals(
                name: "H&M Lifestyle",
                deliverable: [
                    Deliverable(
                        name: "Reel Concept Ideation",
                        deadline: DateFormat(day: "Tuesday", date: Date(), time: DateComponents(hour: 9, minute: 00)
                        )
                    ),
                    Deliverable(
                        name: "Final Reel Submission",
                        deadline: DateFormat(day: "Friday", date: Date(), time: DateComponents(hour: 17, minute: 00)
                        )
                    )
                ],
                platform: [.instagram],
                phone: "9090909090",
                email: "hm.lifestyle@gmail.com",
                description: "Create a reel showcasing winter streetwear.",
                payment: 7000,
                selectedIdea: ideas
                ),
            Deals(
                name: "Nykaa Beauty",
                deliverable: [
                    Deliverable(
                        name: "Makeup Tutorial Script",
                        deadline: DateFormat(day: "Monday", date: Date(), time: DateComponents(hour: 12, minute: 45)
                        )
                    ),
                    Deliverable(
                        name: "Final Tutorial Video",
                        deadline: DateFormat(day: "Thursday", date: Date(), time: DateComponents(hour: 17, minute: 15)
                        )
                    )
                ],
                platform: [.instagram, .facebook],
                phone: "9345567890",
                email: "collabs@nykaa.com",
                description: "Tutorial using newly launched lipstick shades.",
                payment: 6000,
                selectedIdea: ideas
            ),
            Deals(
                name: "Myntra",
                deliverable: [
                    Deliverable(
                        name: "Try-On Reel Shoot",
                        deadline: DateFormat(day: "Tuesday", date: Date(), time: DateComponents(hour: 13, minute: 30)
                        )
                    ),
                    Deliverable(
                        name: "Final Reel Edit",
                        deadline: DateFormat(day: "Friday", date: Date(), time: DateComponents(hour: 19, minute: 00)
                        )
                    )
                ],
                platform: [.instagram],
                phone: "9123456701",
                email: "campaign@myntra.com",
                description: "Try-on haul for winter jackets.",
                payment: 8000,
                selectedIdea: ideas
            )
        ]
        self.deals = sampleDeals
    }
    
    func postsData() {
        let samplePosts: [Posts] = [
            Posts(
                name: "IG Reel – Morning Skincare Routine",
                postingTime: DateFormat(
                    day: "Monday",
                    date: Date(),
                    time: DateComponents(hour: 10, minute: 00)
                ),
                platform: [.instagram],
                description: "Posting a quick morning skincare routine reel for audience engagement.",
                reminder: ["1 hour before", "10 minutes before"]
            ),
            Posts(
                name: "YouTube Vlog – Week in My Life",
                postingTime: DateFormat(
                    day: "Wednesday",
                    date: Date(),
                    time: DateComponents(hour: 18, minute: 30)
                ),
                platform: [.youtube],
                description: "Full vlog showing weekly lifestyle, workouts, filming and routine.",
                reminder: ["2 hours before"]
            ),
            Posts(
                name: "Instagram Carousel – Outfit Inspirations",
                postingTime: DateFormat(
                    day: "Friday",
                    date: Date(),
                    time: DateComponents(hour: 14, minute: 00)
                ),
                platform: [.instagram],
                description: "Aesthetic outfit inspiration carousel post.",
                reminder: ["30 minutes before", "5 minutes before"]
            ),
            Posts(
                name: "Facebook Update – Festival Sale Promo",
                postingTime: DateFormat(
                    day: "Tuesday",
                    date: Date(),
                    time: DateComponents(hour: 11, minute: 15)
                ),
                platform: [.facebook],
                description: "Short promotional post about the festival sale.",
                reminder: ["1 hour before"]
            ),
            Posts(
                name: "YouTube Shorts – GRWM for Dinner",
                postingTime: DateFormat(
                    day: "Saturday",
                    date: Date(),
                    time: DateComponents(hour: 17, minute: 45)
                ),
                platform: [.youtube, .instagram],
                description: "Short GRWM clip for dinner outing.",
                reminder: ["15 minutes before"]
            ),
            Posts(
                name: "IG Story – New Product Sneak Peek",
                postingTime: DateFormat(
                    day: "Sunday",
                    date: Date(),
                    time: DateComponents(hour: 9, minute: 30)
                ),
                platform: [.instagram],
                description: "Teaser story showing behind-the-scenes of an upcoming product collab.",
                reminder: ["1 hour before", "10 minutes before"]
            )
        ]
        self.posts = samplePosts
    }
    
    func analysisData() {
        let sampleYoutubeAnalysis: [Analysis] = [
            Analysis(
                views: 5.2,
                likes: 3.1,
                incFollowers: "8k",
                followers: "40k",
                ageGroup: ["18", "34"],
                gender: ["M": 45.2, "F": 54.8],
                post: 5,
                optimalTime: [
                    DateFormat(day: "Wednesday", date: Date(), time: DateComponents(hour: 14, minute: 0)),
                    DateFormat(day: "Saturday", date: Date(), time: DateComponents(hour: 10, minute: 30))
                ],
                engagementRate: 6.1
            ),
            Analysis(
                views: 3.8,
                likes: 2.5,
                incFollowers: "3k",
                followers: "28k",
                ageGroup: ["20", "29"],
                gender: ["M": 51.0, "F": 49.0],
                post: 4,
                optimalTime: [
                    DateFormat(day: "Monday", date: Date(), time: DateComponents(hour: 16)),
                    DateFormat(day: "Thursday", date: Date(), time: DateComponents(hour: 11))
                ],
                engagementRate: 4.8
            ),
            Analysis(
                views: 7.4,
                likes: 5.6,
                incFollowers: "12k",
                followers: "55k",
                ageGroup: ["25", "40"],
                gender: ["M": 40.4, "F": 59.6],
                post: 6,
                optimalTime: [
                    DateFormat(day: "Tuesday", date: Date(), time: DateComponents(hour: 18)),
                    DateFormat(day: "Friday", date: Date(), time: DateComponents(hour: 15))
                ],
                engagementRate: 7.3
            )
        ]

        let sampleInstagramAnalysis: [Analysis] = [
            Analysis(
                views: 4.5,
                likes: 3.9,
                incFollowers: "6k",
                followers: "30k",
                ageGroup: ["18", "29"],
                gender: ["M": 33.1, "F": 66.9],
                post: 7,
                optimalTime: [
                    DateFormat(day: "Monday", date: Date(), time: DateComponents(hour: 9)),
                    DateFormat(day: "Friday", date: Date(), time: DateComponents(hour: 13))
                ],
                engagementRate: 5.7
            ),
            Analysis(
                views: 6.1,
                likes: 4.8,
                incFollowers: "10k",
                followers: "52k",
                ageGroup: ["21", "35"],
                gender: ["M": 41.7, "F": 58.3],
                post: 8,
                optimalTime: [
                    DateFormat(day: "Tuesday", date: Date(), time: DateComponents(hour: 17)),
                    DateFormat(day: "Sunday", date: Date(), time: DateComponents(hour: 11))
                ],
                engagementRate: 6.3
            ),
            Analysis(
                views: 3.2,
                likes: 2.1,
                incFollowers: "2k",
                followers: "18k",
                ageGroup: ["19", "27"],
                gender: ["M": 29.8, "F": 70.2],
                post: 3,
                optimalTime: [
                    DateFormat(day: "Wednesday", date: Date(), time: DateComponents(hour: 14)),
                    DateFormat(day: "Saturday", date: Date(), time: DateComponents(hour: 9))
                ],
                engagementRate: 3.9
            )
        ]

        let sampleFacebookAnalysis: [Analysis] = [
            Analysis(
                views: 2.2,
                likes: 1.2,
                incFollowers: "1k",
                followers: "10k",
                ageGroup: ["25", "44"],
                gender: ["M": 48.0, "F": 52.0],
                post: 2,
                optimalTime: [
                    DateFormat(day: "Thursday", date: Date(), time: DateComponents(hour: 19)),
                    DateFormat(day: "Sunday", date: Date(), time: DateComponents(hour: 12))
                ],
                engagementRate: 2.9
            ),
            Analysis(
                views: 4.4,
                likes: 2.8,
                incFollowers: "3.4k",
                followers: "22k",
                ageGroup: ["30", "50"],
                gender: ["M": 55.3, "F": 44.7],
                post: 3,
                optimalTime: [
                    DateFormat(day: "Monday", date: Date(), time: DateComponents(hour: 18)),
                    DateFormat(day: "Friday", date: Date(), time: DateComponents(hour: 14))
                ],
                engagementRate: 4.2
            ),
            Analysis(
                views: 3.7,
                likes: 2.0,
                incFollowers: "1.8k",
                followers: "15k",
                ageGroup: ["28", "47"],
                gender: ["M": 50.5, "F": 49.5],
                post: 4,
                optimalTime: [
                    DateFormat(day: "Wednesday", date: Date(), time: DateComponents(hour: 16)),
                    DateFormat(day: "Saturday", date: Date(), time: DateComponents(hour: 11))
                ],
                engagementRate: 3.5
            )
        ]

        self.youtubeAnalysis = sampleYoutubeAnalysis
        self.instagramAnalysis = sampleInstagramAnalysis
        self.facebookAnalysis = sampleFacebookAnalysis
    }
}
