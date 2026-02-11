//
//  TrendingVideoCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class TrendingVideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configureVideo(video: Video) {
        imageView.image = UIImage(named: video.thumbnail)
        if let url = URL(string: video.thumbnail) {
            loadImage(from: url)
        }
        titleLabel.text = video.title
        titleLabel.numberOfLines = 2
        viewsLabel.text = formatCount(video.views)
        likesLabel.text = formatCount(video.likes)
    }
    
    func loadImage(from url: URL) {
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                print("❌ Image download error:", error)
                return
            }
            
            guard let data = data,
                  let image = UIImage(data: data) else {
                print("❌ Invalid image data")
                return
            }
            
            DispatchQueue.main.async {
                self.imageView.image = image
            }
            
        }.resume()
    }
    
    func formatCount(_ number: Int) -> String {

        switch number {
        case 0..<1_000:
            return "\(number)"

        case 1_000..<1_000_000:
            let value = Double(number) / 1_000
            return String(format: "%.1fK", value).replacingOccurrences(of: ".0", with: "")

        case 1_000_000..<1_000_000_000:
            let value = Double(number) / 1_000_000
            return String(format: "%.1fM", value).replacingOccurrences(of: ".0", with: "")

        default:
            let value = Double(number) / 1_000_000_000
            return String(format: "%.1fB", value).replacingOccurrences(of: ".0", with: "")
        }
    }
}
