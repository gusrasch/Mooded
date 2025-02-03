import Foundation

class MoodStore: ObservableObject {
    @Published private(set) var moods: [Mood] = []
    private let saveKey = "SavedMoods"
    
    init() {
        load()
    }
    
    func add(_ mood: Mood) {
        moods.append(mood)
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(moods) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Mood].self, from: data) {
            moods = decoded
        }
    }
}
