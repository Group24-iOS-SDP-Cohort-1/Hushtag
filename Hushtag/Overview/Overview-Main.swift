//
//  Overview-Main.swift
//  Hushtag
//
//  Created by SDC-USER on 17/11/25.
//

import UIKit
class Overview_Main: UIViewController {
    @IBOutlet weak var ScheduleStack: UIScrollView!
    @IBOutlet weak var AnalysisStack: UIStackView!
    @IBOutlet weak var SuggestedStack: UIStackView!
    @IBOutlet weak var mainScroll: UIScrollView!
    @IBOutlet weak var Content: UIStackView!
    
    let items = ["Past week", "Past month", "Past 3 months"]
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToYoutubeAnalysis" {
            let destination = segue.destination as! YoutubeAnalysis
            destination.someProperty = "value"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Create cards
        let card1 = CardView(time: "09:00", date: "Today", title: "Makeup tutorial for festive season", platform: "YouTube")
        let card2 = CardView(time: "14:30", date: "Today", title: "Meeting with designers", platform: "Facebook")
        let card3 = CardView(time: "18:00", date: "Today", title: "Script finalization for video #3", platform: "Instagram")
        let card4 = AnalysisCard(value: "16%", sf: "increase", category: "Youtube")
        let card5 = AnalysisCard(value: "--", sf: " ", category: "Instagram")
        let card6 = AnalysisCard(value: "3%", sf: "decrease", category: "Facebook")
        let card7 = SuggestedForYou(trending: "Fashion", title: "Unlock Your Style: Must-Know Fashion Hacks!", description: "Make a video showing your stylish everyday work looks.", hashtag1: "#style", hashtag2: "#beauty")
        let card8 = SuggestedForYou(trending: "Lifestyle", title: "Morning Routine, Coffee Run, Studying | Vlog", description: "Make a video showing your productive morning routine.", hashtag1: "#fashion", hashtag2: "#style")
        
        // Card layout setup
        [card1, card2, card3].forEach { card in card.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([ card.widthAnchor.constraint(equalToConstant: 175), card.heightAnchor.constraint(equalToConstant: 144) ]) }
        
        [card7, card8].forEach { card in card.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([ card.widthAnchor.constraint(equalToConstant: 358), card.heightAnchor.constraint(equalToConstant: 182) ]) }
        
        [card4, card5, card6].forEach { card in card.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([ card.widthAnchor.constraint(equalToConstant: 110), card.heightAnchor.constraint(equalToConstant: 115) ]) }
        let cardsStack = UIStackView(arrangedSubviews: [card1, card2, card3])
        cardsStack.axis = .horizontal
        cardsStack.spacing = 12
        cardsStack.alignment = .center
        cardsStack.distribution = .equalSpacing
        cardsStack.translatesAutoresizingMaskIntoConstraints = false
        let analysisStack = UIStackView(arrangedSubviews: [card4, card5, card6])
        analysisStack.axis = .horizontal
        analysisStack.spacing = 15
        analysisStack.alignment = .center
        analysisStack.distribution = .equalSpacing
        analysisStack.translatesAutoresizingMaskIntoConstraints = false
        let suggestedForYou = UIStackView(arrangedSubviews: [card7, card8])
        suggestedForYou.axis = .vertical
        suggestedForYou.spacing = 15
        suggestedForYou.translatesAutoresizingMaskIntoConstraints = false
        
        ScheduleStack.addSubview(cardsStack)
        AnalysisStack.addSubview(analysisStack)
        SuggestedStack.addSubview(suggestedForYou)
        NSLayoutConstraint.activate([ cardsStack.leadingAnchor.constraint(equalTo: ScheduleStack.contentLayoutGuide.leadingAnchor, constant: 4), cardsStack.trailingAnchor.constraint(equalTo: ScheduleStack.contentLayoutGuide.trailingAnchor, constant: 15), cardsStack.topAnchor.constraint(equalTo: ScheduleStack.contentLayoutGuide.topAnchor), cardsStack.bottomAnchor.constraint(equalTo: ScheduleStack.contentLayoutGuide.bottomAnchor), cardsStack.heightAnchor.constraint(equalTo: ScheduleStack.frameLayoutGuide.heightAnchor) ])
        ScheduleStack.showsHorizontalScrollIndicator = false
        ScheduleStack.alwaysBounceHorizontal = true
        NSLayoutConstraint.activate([ Content.leadingAnchor.constraint(equalTo: mainScroll.contentLayoutGuide.leadingAnchor, constant: 4), Content.trailingAnchor.constraint(equalTo: mainScroll.contentLayoutGuide.trailingAnchor), Content.topAnchor.constraint(equalTo: mainScroll.contentLayoutGuide.topAnchor), Content.bottomAnchor.constraint(equalTo: mainScroll.contentLayoutGuide.bottomAnchor), Content.heightAnchor.constraint(equalTo: mainScroll.frameLayoutGuide.heightAnchor) ])
        mainScroll.showsVerticalScrollIndicator = false
        mainScroll.alwaysBounceVertical = true
        
        card4.onTap = { [weak self] in self?.performSegue(withIdentifier: "goToYoutubeAnalysis", sender: nil)
        }
        card5.onTap = { [weak self] in self?.performSegue(withIdentifier: "goToInstagramAnalysis", sender: nil)
        }
        card6.onTap = { [weak self] in self?.performSegue(withIdentifier: "goToFacebookAnalysis", sender: nil)
        }
    }
}
