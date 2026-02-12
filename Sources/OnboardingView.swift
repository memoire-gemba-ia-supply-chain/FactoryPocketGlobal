import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Premium Background
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.15)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Icon / Logo Placeholder
                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 5)
                
                // Title
                Text(L10n.premiumWelcome)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                // Badge
                Text(L10n.premiumBadge.uppercased())
                    .font(.caption)
                    .fontWeight(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                
                Spacer()
                
                // Offer Card
                VStack(spacing: 15) {
                    Text(L10n.limitedOffer)
                        .font(.headline)
                        .foregroundColor(.gray)
                        .textCase(.uppercase)
                    
                    Text(L10n.lifeTimeAccess)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Divider().background(Color.gray)
                    
                    Text("$0.00")
                        .font(.system(size: 50, weight: .heavy))
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
                .padding(.horizontal)
                
                Spacer()
                
                // Action Button
                Button(action: {
                    isPresented = false
                }) {
                    Text(L10n.claimOffer)
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(15)
                        .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
                
                Button(action: {
                    isPresented = false
                }) {
                    Text(L10n.startUsing)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
