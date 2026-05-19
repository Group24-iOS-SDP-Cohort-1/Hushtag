import UIKit

class TopContentCollectionViewCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var viewsLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        applyLiquidGlassEffect()
    }

    func configure(with item: TopVideo) {
        titleLabel.text = item.title
        titleLabel.numberOfLines = 1
        viewsLabel.text = "\(item.views.formattedCount()) views • \(item.publishedAt.dateAndMonth())"
        thumbnailImageView.loadImage(from: item.thumbnail)
    }
}

/// to load thumbnail
extension UIImageView {
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }

        Task {
            do {
                let (data, _) =
                    try await URLSession.shared.data(from: url)

                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.image = image
                    }
                }
            } catch {
                print("Image load failed:", error)
            }
        }
    }
}
