//
//  DataStore.swift
//  Hushtag
//
//  Created by SDC-USER on 05/01/26.
//

import Foundation

class DataStore {
    private var deals: [Deal] = []
    private var posts: [Post] = []
    //private var analysis: [Analysis] = []
    
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

    func loadSampleData() {
        let sampleTasks: [Task] = [
            Task(
                name: "Everyday Glam Makeup Reel",
                deadline: DateData(
                    day: "Monday",
                    date: "2025-11-18T00:00:00Z",
                    time: TimeData(hour: 10, minute: 0)
                ),
                isCompleted: false
            ),
            
            Task(
                name: "Unboxing New Cosmetic Products",
                deadline: DateData(
                    day: "Tuesday",
                    date: "2025-11-19T00:00:00Z",
                    time: TimeData(hour: 11, minute: 0)
                ),
                isCompleted: true
            ),
            
            Task(
                name: "Recreate Model Look",
                deadline: DateData(
                    day: "Wednesday",
                    date: "2026-1-13T00:00:00Z",
                    time: TimeData(hour: 9, minute: 30)
                ),
                isCompleted: false
            ),
            
            Task(
                name: "Edit & Schedule Instagram Post",
                deadline: DateData(
                    day: "Thursday",
                    date: "2026-1-14T00:00:00Z",
                    time: TimeData(hour: 15, minute: 0)
                ),
                isCompleted: true
            ),
            
            Task(
                name: "Research Upcoming Beauty Trends",
                deadline: DateData(
                    day: "Friday",
                    date: "2025-11-22T00:00:00Z",
                    time: TimeData(hour: 10, minute: 0)
                ),
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
                platform: ["instagram"],
                tasks: [sampleTasks[0], sampleTasks[3]],
                reminder: ["1 hour before", "15 minutes before"]
            ),
            
            Post(
                name: "YouTube Video – Studio Makeup Tutorial",
                platform: ["youtube"],
                tasks: [],
                reminder: ["3 hours before"]
            ),
            
            Post(
                name: "Instagram Carousel – Winter Layering Looks",
                platform: ["instagram"],
                tasks: sampleTasks,
                reminder: ["45 minutes before"]
            ),
            
            Post(
                name: "Facebook Post – Brand Giveaway Announcement",
                platform: ["facebook"],
                tasks: [],
                reminder: ["2 hours before"]
            ),
            
            Post(
                name: "YouTube Shorts – Quick GRWM Coffee Date",
                platform: ["youtube", "instagram"],
                tasks: [sampleTasks[2]],
                reminder: ["20 minutes before"]
            ),
            
            Post(
                name: "IG Story – Behind the Scenes Shoot",
                platform: ["instagram"],
                tasks: [],
                reminder: ["30 minutes before", "5 minutes before"]
            )
        ]

        self.deals = sampleDeals
        self.posts = samplePosts
    }
}
