import SwiftUI

struct AudienceGenderChart: View {

    let malePercentage: Double
    let femalePercentage: Double

    private let accent =
        Color(uiColor: UIColor(named: "AccentColor") ?? .systemPurple)

    var body: some View {

        VStack(spacing: 18) {

            genderBar(
                title: "Male",
                value: malePercentage,
                color: accent.opacity(0.7)
            )

            genderBar(
                title: "Female",
                value: femalePercentage,
                color: accent
            )
        }
        .padding(.leading, 25)
        .padding(.trailing, 12)
        .padding(.bottom, 10)
        .frame(height: 150)
    }

    // MARK: - Horizontal Gender Bar
    private func genderBar(
        title: String,
        value: Double,
        color: Color
    ) -> some View {

        VStack(alignment: .leading, spacing: 8) {

            HStack {

                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.gray)

                Spacer()

                Text("\(String(format: "%.1f", value))%")
                    .font(.caption2)
                    .bold()
            }

            GeometryReader { geo in

                ZStack(alignment: .leading) {

                    // Background Track
                    Capsule()
                        .fill(Color.gray.opacity(0.25))
                        .frame(height: 35)

                    // Filled Bar
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.6),
                                    color
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: max(
                                8,
                                geo.size.width * (value / 100)
                            ),
                            height: 35
                        )
                        .animation(
                            .easeInOut(duration: 0.7),
                            value: value
                        )
                }
            }
            .frame(height: 35)
        }
    }
}
