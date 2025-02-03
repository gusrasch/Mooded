import SwiftUI

struct MoodEntryView: View {
    @ObservedObject var moodStore: MoodStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedRating = 3
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("How are you feeling?")
                    .font(.title)
                
                HStack(spacing: 20) {
                    ForEach(1...5, id: \.self) { rating in
                        Button(action: {
                            selectedRating = rating
                        }) {
                            Text(String(rating))
                                .font(.title)
                                .padding()
                                .background(
                                    Circle()
                                        .fill(rating == selectedRating ? Color.blue : Color.gray.opacity(0.3))
                                )
                                .foregroundColor(rating == selectedRating ? .white : .primary)
                        }
                    }
                }
                
                Button("Save") {
                    moodStore.add(Mood(rating: selectedRating))
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}
