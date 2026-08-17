import SwiftData
import SwiftUI

struct BookDetailView: View {
    let book: Book

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showsDeleteConfirmation = false

    var body: some View {
        List {
            Section {
                Text(book.title)
                    .font(.title2.bold())
                if let authors = book.authors, !authors.isEmpty {
                    Text(authors)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Book information") {
                detailRow("ISBN", value: book.isbn)
                detailRow("Publisher", value: book.publisher)
                if let publicationDate = book.publicationDate {
                    LabeledContent("Publication date", value: publicationDate.formatted(date: .long, time: .omitted))
                }
                detailRow("Language", value: book.language)
            }

            if let description = book.descriptionText, !description.isEmpty {
                Section("Description") {
                    Text(description)
                }
            }

            Section {
                LabeledContent("Date added", value: book.dateAdded.formatted(date: .long, time: .shortened))
            }

            Section {
                Button("Delete book", role: .destructive) {
                    showsDeleteConfirmation = true
                }
            }
        }
        .navigationTitle("Book details")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Delete this book?",
            isPresented: $showsDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete book", role: .destructive) {
                modelContext.delete(book)
                try? modelContext.save()
                dismiss()
            }
        } message: {
            Text("This removes \(book.title) from your catalog.")
        }
    }

    @ViewBuilder
    private func detailRow(_ label: String, value: String?) -> some View {
        if let value, !value.isEmpty {
            LabeledContent(label, value: value)
        }
    }
}
