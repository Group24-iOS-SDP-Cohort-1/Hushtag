//
//  Overview-Main.swift
//  Hushtag
//
//  Created by SDC-USER on 17/11/25.
//

import UIKit

class Overview_Main: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return items[row]
        }

    
    @IBOutlet weak var ScheduleStack: UIScrollView!
    
    @IBOutlet weak var dropdown: UIPickerView!
    
    let items = ["Past week", "Past month", "Past 3 months"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropdown.delegate = self
        dropdown.dataSource = self
        
        let card1 = CardView()
        let card2 = CardView()
        let card3 = CardView()
        
        [card1, card2, card3].forEach { card in
            card.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                card.widthAnchor.constraint(equalToConstant: 175),
                card.heightAnchor.constraint(equalToConstant: 144)
            ])
        }
        
        let cardsStack = UIStackView(arrangedSubviews: [card1, card2, card3])
        cardsStack.axis = .horizontal
        cardsStack.spacing = 12
        cardsStack.alignment = .center
        cardsStack.distribution = .equalSpacing
        cardsStack.translatesAutoresizingMaskIntoConstraints = false
        
        ScheduleStack.addSubview(cardsStack)
        
        
        NSLayoutConstraint.activate([
            cardsStack.leadingAnchor.constraint(equalTo: ScheduleStack.contentLayoutGuide.leadingAnchor, constant: 4), // no spacing before first card
            cardsStack.trailingAnchor.constraint(equalTo: ScheduleStack.contentLayoutGuide.trailingAnchor, constant: 15),
            cardsStack.topAnchor.constraint(equalTo: ScheduleStack.contentLayoutGuide.topAnchor),
            cardsStack.bottomAnchor.constraint(equalTo: ScheduleStack.contentLayoutGuide.bottomAnchor),
            
            // Match height to scroll view to prevent vertical scrolling
            cardsStack.heightAnchor.constraint(equalTo: ScheduleStack.frameLayoutGuide.heightAnchor)
        ])
        
        // Optional: enable horizontal scrolling
        ScheduleStack.showsHorizontalScrollIndicator = false
        ScheduleStack.alwaysBounceHorizontal = true
    }
    

}
