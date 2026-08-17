import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "No books yet",
                systemImage: "books.vertical",
                description: Text("Add a book manually or scan its ISBN to begin your catalog.")
            )
            .navigationTitle("My Books")
        }
    }
}

#Preview {
    ContentView()
}
