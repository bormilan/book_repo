import SwiftData
import SwiftUI

struct ManualBookForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var draft: ManualBookDraft
    @State private var saveErrorMessage: String?

    init(prefilledISBN: String? = nil) {
        _draft = State(initialValue: ManualBookDraft(prefilledISBN: prefilledISBN))
    }

    var body: some View {
        Form {
            Section("Required") {
                TextField("Title", text: $draft.title)
            }

            Section("Book information") {
                TextField("Author(s)", text: $draft.authors)
                TextField("ISBN", text: $draft.isbn)
                    .keyboardType(.numberPad)
                if let message = draft.isbnValidationMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
                TextField("Publisher", text: $draft.publisher)
                Toggle("Add publication date", isOn: $draft.includesPublicationDate)
                if draft.includesPublicationDate {
                    DatePicker("Publication date", selection: $draft.publicationDate, displayedComponents: .date)
                }
                TextField("Language", text: $draft.language)
                TextField("Description", text: $draft.descriptionText, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .navigationTitle("Add book")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveBook()
                }
                .disabled(!draft.canSave)
            }
        }
        .alert("Couldn't save book", isPresented: showsSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveErrorMessage ?? "Please try again.")
        }
    }

    private var showsSaveError: Binding<Bool> {
        Binding(
            get: { saveErrorMessage != nil },
            set: { if !$0 { saveErrorMessage = nil } }
        )
    }

    private func saveBook() {
        guard draft.canSave else { return }

        let repository = BookRepository(modelContext: modelContext)
        do {
            _ = try repository.create(
                title: draft.title.trimmingCharacters(in: .whitespacesAndNewlines),
                authors: draft.optionalValue(draft.authors),
                isbn: draft.optionalValue(draft.isbn),
                publisher: draft.optionalValue(draft.publisher),
                publicationDate: draft.optionalPublicationDate,
                language: draft.optionalValue(draft.language),
                descriptionText: draft.optionalValue(draft.descriptionText)
            )
            dismiss()
        } catch BookRepositoryError.duplicateISBN {
            saveErrorMessage = "A book with this ISBN is already in your catalog."
        } catch {
            saveErrorMessage = "The book could not be saved."
        }
    }
}
