//
//  DataStore.swift
//  Hushtag
//
//  Created by SDC-USER on 05/01/26.
//

import Foundation

class DataStore {
    private var tasks: [Task] = []
    private var deals: [Deal] = []
    private var posts: [Post] = []
    private var analysis: [Analysis] = []
    
    static let shared = DataStore()
    
    private init() {
        loadSampleData()
    }
    func getTasks() -> [Task] {
        tasks
    }
    func getDeals() -> [Deal] {
        deals
    }
    func getPosts() -> [Post] {
        posts
    }
    func getAnalysis() -> [Analysis] {
        analysis
    }
    
    func loadSampleData() {
        let sampleTasks: [Task] = [
            Task(
                name: "Everyday Glam Makeup Reel",
                startDate: DateData(
                    day: "Monday",
                    date: "2025-11-18T00:00:00Z",
                    time: TimeData(hour: 10, minute: 0)
                ),
                endDate: DateData(
                    day: "Monday",
                    date: "2025-11-18T00:00:00Z",
                    time: TimeData(hour: 13, minute: 0)
                ),
                description: "Create a soft everyday glam makeup reel highlighting natural skin and subtle eyes.",
                reminder: ["1 hour before", "15 mins before"],
                isCompleted: false
            ),

            Task(
                name: "Unboxing New Cosmetic Products",
                startDate: DateData(
                    day: "Tuesday",
                    date: "2025-11-19T00:00:00Z",
                    time: TimeData(hour: 11, minute: 0)
                ),
                endDate: DateData(
                    day: "Tuesday",
                    date: "2025-11-19T00:00:00Z",
                    time: TimeData(hour: 14, minute: 0)
                ),
                description: "Unbox and review newly received cosmetic products and record short clips.",
                reminder: ["30 mins before"],
                isCompleted: true
            ),

            Task(
                name: "Recreate Model Look",
                startDate: DateData(
                    day: "Wednesday",
                    date: "2025-11-20T00:00:00Z",
                    time: TimeData(hour: 9, minute: 30)
                ),
                endDate: DateData(
                    day: "Wednesday",
                    date: "2025-11-20T00:00:00Z",
                    time: TimeData(hour: 12, minute: 0)
                ),
                description: "Recreate a trending model look and showcase products used step-by-step.",
                reminder: ["1 hour before"],
                isCompleted: false
            ),

            Task(
                name: "Edit & Schedule Instagram Post",
                startDate: DateData(
                    day: "Thursday",
                    date: "2025-11-21T00:00:00Z",
                    time: TimeData(hour: 15, minute: 0)
                ),
                endDate: DateData(
                    day: "Thursday",
                    date: "2025-11-21T00:00:00Z",
                    time: TimeData(hour: 17, minute: 0)
                ),
                description: "Edit selected clips, add captions and hashtags, and schedule the Instagram post.",
                reminder: ["45 mins before"],
                isCompleted: false
            ),

            Task(
                name: "Research Upcoming Beauty Trends",
                startDate: DateData(
                    day: "Friday",
                    date: "2025-11-22T00:00:00Z",
                    time: TimeData(hour: 10, minute: 0)
                ),
                endDate: DateData(
                    day: "Friday",
                    date: "2025-11-22T00:00:00Z",
                    time: TimeData(hour: 12, minute: 0)
                ),
                description: "Research upcoming beauty and makeup trends to plan next week’s content.",
                reminder: ["1 hour before"],
                isCompleted: false
            )
        ]
        
        let sampleDeals: [Deal] = [
            Deal(
                name: "NARS Cosmetics",
                deliverable: [
                    Deliverable(
                        name: "IG Concept Draft",
                        deadline: DateData(
                            day: "Monday",
                            date: "2025-11-18T00:00:00Z",
                            time: TimeData(hour: 10, minute: 30)
                        ),
                        isCompleted: true
                    ),
                    Deliverable(
                        name: "Final IG Carousel",
                        deadline: DateData(
                            day: "Wednesday",
                            date: "2025-11-20T00:00:00Z",
                            time: TimeData(hour: 16, minute: 0)
                        ),
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
                        deadline: DateData(
                            day: "Tuesday",
                            date: "2025-11-19T00:00:00Z",
                            time: TimeData(hour: 9, minute: 0)
                        ),
                        isCompleted: true
                    ),
                    Deliverable(
                        name: "Streetwear Reel Shoot",
                        deadline: DateData(
                            day: "Thursday",
                            date: "2025-11-21T00:00:00Z",
                            time: TimeData(hour: 14, minute: 30)
                        ),
                        isCompleted: false
                    ),
                    Deliverable(
                        name: "Final Reel Edit",
                        deadline: DateData(
                            day: "Saturday",
                            date: "2025-11-23T00:00:00Z",
                            time: TimeData(hour: 18, minute: 0)
                        ),
                        isCompleted: false
                    )
                ],
                platform: ["instagram"],
                phone: "9090909090",
                email: "lifestyle@hm.com",
                description: "Winter streetwear reel series.",
                payment: 7000,
                selectedIdeaIndex: "i2"
            ),

            Deal(
                name: "Nykaa Beauty",
                deliverable: [
                    Deliverable(
                        name: "Lipstick Tutorial Video",
                        deadline: DateData(
                            day: "Friday",
                            date: "2025-11-22T00:00:00Z",
                            time: TimeData(hour: 17, minute: 15)
                        ),
                        isCompleted: false
                    )
                ],
                platform: ["facebook"],
                phone: "9345567890",
                email: "collabs@nykaa.com",
                description: "Tutorial featuring newly launched lipstick shades.",
                payment: 6000,
                selectedIdeaIndex: "i3"
            ),

            Deal(
                name: "Myntra",
                deliverable: [
                    Deliverable(
                        name: "Try-On Reel Shoot",
                        deadline: DateData(
                            day: "Thursday",
                            date: "2025-11-21T00:00:00Z",
                            time: TimeData(hour: 13, minute: 30)
                        ),
                        isCompleted: true
                    ),
                    Deliverable(
                        name: "Final Reel Upload",
                        deadline: DateData(
                            day: "Sunday",
                            date: "2025-11-24T00:00:00Z",
                            time: TimeData(hour: 19, minute: 0)
                        ),
                        isCompleted: true
                    )
                ],
                platform: ["instagram"],
                phone: "9123456701",
                email: "campaign@myntra.com",
                description: "Winter jacket try-on haul.",
                payment: 8000,
                selectedIdeaIndex: "i4"
            ),
            
            Deal(
                name: "Lakmé India",
                deliverable: [
                    Deliverable(
                        name: "Product Teaser Shoot",
                        deadline: DateData(
                            day: "Monday",
                            date: "2025-11-25T00:00:00Z",
                            time: TimeData(hour: 11, minute: 0)
                        ),
                        isCompleted: false
                    ),
                    Deliverable(
                        name: "Brand Reel Editing",
                        deadline: DateData(
                            day: "Wednesday",
                            date: "2025-11-27T00:00:00Z",
                            time: TimeData(hour: 15, minute: 45)
                        ),
                        isCompleted: false
                    ),
                    Deliverable(
                        name: "Final Campaign Upload",
                        deadline: DateData(
                            day: "Friday",
                            date: "2025-11-29T00:00:00Z",
                            time: TimeData(hour: 18, minute: 30)
                        ),
                        isCompleted: false
                    )
                ],
                platform: ["youtube"],
                phone: "9876543210",
                email: "brand@lakmeindia.com",
                description: "Matte foundation launch campaign.",
                payment: 9000,
                selectedIdeaIndex: "i5"
            )
        ]
        
        let samplePosts: [Post] = [
            Post(
                name: "IG Reel – Nighttime Skincare Reset",
                postingTime: DateData(
                    day: "Tuesday",
                    date: "2025-12-02T00:00:00Z",
                    time: TimeData(hour: 21, minute: 0)
                ),
                platform: ["instagram"],
                description: "Relaxing nighttime skincare routine focusing on hydration and barrier repair.",
                reminder: ["1 hour before", "15 minutes before"],
                isCompleted: false
            ),

            Post(
                name: "YouTube Video – Studio Makeup Tutorial",
                postingTime: DateData(
                    day: "Thursday",
                    date: "2025-12-04T00:00:00Z",
                    time: TimeData(hour: 19, minute: 30)
                ),
                platform: ["youtube"],
                description: "Detailed makeup tutorial filmed in studio lighting with pro tips.",
                reminder: ["3 hours before"],
                isCompleted: false
            ),

            Post(
                name: "Instagram Carousel – Winter Layering Looks",
                postingTime: DateData(
                    day: "Saturday",
                    date: "2025-12-06T00:00:00Z",
                    time: TimeData(hour: 13, minute: 0)
                ),
                platform: ["instagram"],
                description: "Carousel showcasing cozy winter layering outfit inspirations.",
                reminder: ["45 minutes before"],
                isCompleted: true
            ),

            Post(
                name: "Facebook Post – Brand Giveaway Announcement",
                postingTime: DateData(
                    day: "Monday",
                    date: "2025-12-01T00:00:00Z",
                    time: TimeData(hour: 11, minute: 45)
                ),
                platform: ["facebook"],
                description: "Giveaway announcement post with contest rules and deadline.",
                reminder: ["2 hours before"],
                isCompleted: true
            ),

            Post(
                name: "YouTube Shorts – Quick GRWM Coffee Date",
                postingTime: DateData(
                    day: "Friday",
                    date: "2025-12-05T00:00:00Z",
                    time: TimeData(hour: 17, minute: 15)
                ),
                platform: ["youtube", "instagram"],
                description: "Fast-paced GRWM short clip before heading out for a coffee date.",
                reminder: ["20 minutes before"],
                isCompleted: false
            ),

            Post(
                name: "IG Story – Behind the Scenes Shoot",
                postingTime: DateData(
                    day: "Sunday",
                    date: "2025-12-07T00:00:00Z",
                    time: TimeData(hour: 10, minute: 0)
                ),
                platform: ["instagram"],
                description: "Casual behind-the-scenes story from an ongoing photoshoot.",
                reminder: ["30 minutes before", "5 minutes before"],
                isCompleted: false
            )
        ]
        
        let sampleAnalysis: [Analysis] = [

            Analysis(
                id: "1",
                views: "5.2k",
                likes: "3.1k",
                incFollowers: "-8k",
                followers: "40k",
                ageGroup: ["18", "34"],
                gender: [
                    "M": "45.2",
                    "F": "54.8"
                ],
                post: 5,
                optimalTime: [
                    AnalysisDateData(
                        day: "Monday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 17, minute: 0),
                        audienceEngagementRate: "6.1"
                    ),
                    AnalysisDateData(
                        day: "Tuesday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 14, minute: 0),
                        audienceEngagementRate: "4.3"
                    ),
                    AnalysisDateData(
                        day: "Wednesday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 14, minute: 0),
                        audienceEngagementRate: "1.7"
                    ),
                    AnalysisDateData(
                        day: "Thursday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 9, minute: 0),
                        audienceEngagementRate: "5.4"
                    ),
                    AnalysisDateData(
                        day: "Friday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 14, minute: 0),
                        audienceEngagementRate: "3.2"
                    ),
                    AnalysisDateData(
                        day: "Saturday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 10, minute: 30),
                        audienceEngagementRate: "2.5"
                    ),
                    AnalysisDateData(
                        day: "Sunday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 14, minute: 0),
                        audienceEngagementRate: "4.1"
                    )
                ],
                engagementRate: "6.1"
            ),

            Analysis(
                id: "2",
                views: "3.8k",
                likes: "2.5k",
                incFollowers: "3k",
                followers: "28k",
                ageGroup: ["20", "29"],
                gender: [
                    "M": "51",
                    "F": "49"
                ],
                post: 4,
                optimalTime: [
                    AnalysisDateData(
                        day: "Monday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 16, minute: 0),
                        audienceEngagementRate: "1.0"
                    ),
                    AnalysisDateData(
                        day: "Tuesday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 17, minute: 0),
                        audienceEngagementRate: "6.1"
                    ),
                    AnalysisDateData(
                        day: "Wednesday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 17, minute: 0),
                        audienceEngagementRate: "6.1"
                    ),
                    AnalysisDateData(
                        day: "Thursday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 11, minute: 0),
                        audienceEngagementRate: "1.0"
                    ),
                    AnalysisDateData(
                        day: "Friday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 17, minute: 0),
                        audienceEngagementRate: "6.1"
                    ),
                    AnalysisDateData(
                        day: "Saturday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 17, minute: 0),
                        audienceEngagementRate: "6.2"
                    ),
                    AnalysisDateData(
                        day: "Sunday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 17, minute: 0),
                        audienceEngagementRate: "6.7"
                    )
                ],
                engagementRate: ""
            ),

            Analysis(
                id: "3",
                views: "7.4k",
                likes: "5.6k",
                incFollowers: "12k",
                followers: "55k",
                ageGroup: ["25", "40"],
                gender: [
                    "M": "40.4",
                    "F": "59.6"
                ],
                post: 6,
                optimalTime: [
                    AnalysisDateData(
                        day: "Monday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 17, minute: 0),
                        audienceEngagementRate: "6.1"
                    ),
                    AnalysisDateData(
                        day: "Tuesday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 18, minute: 0),
                        audienceEngagementRate: "7.6"
                    ),
                    AnalysisDateData(
                        day: "Wednesday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 17, minute: 0),
                        audienceEngagementRate: "6.1"
                    ),
                    AnalysisDateData(
                        day: "Thursday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 17, minute: 0),
                        audienceEngagementRate: "6.1"
                    ),
                    AnalysisDateData(
                        day: "Friday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 15, minute: 0),
                        audienceEngagementRate: "1.0"
                    ),
                    AnalysisDateData(
                        day: "Saturday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 17, minute: 0),
                        audienceEngagementRate: "6.1"
                    ),
                    AnalysisDateData(
                        day: "Sunday",
                        date: "2025-11-19T00:00:00Z",
                        time: TimeData(hour: 17, minute: 0),
                        audienceEngagementRate: "7.2"
                    )
                ],
                engagementRate: "-7.3"
            )
        ]

        self.tasks = sampleTasks
        self.deals = sampleDeals
        self.posts = samplePosts
        self.analysis = sampleAnalysis
    }
}
