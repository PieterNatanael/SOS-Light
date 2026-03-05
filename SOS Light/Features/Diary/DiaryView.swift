import SwiftUI

struct DiaryView: View {
    @ObservedObject var dataStore: DataStore
    @State private var newText: String = ""
    @State private var selectedAngerLevel: String = "Low"
    @State private var showAdsAndAppFunctionality = false
    @FocusState private var isEditorFocused: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(white: 0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 14) {
                HStack {
                    Text("SOS DIARY")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .tracking(1.8)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        showAdsAndAppFunctionality = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color.white)
                            .padding(10)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
                            )
                    }
                }

                ZStack(alignment: .topLeading) {
                    if newText.isEmpty {
                        Text("Write down your SOS Notes here...")
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                    }

                    TextEditor(text: $newText)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .frame(minHeight: 96, maxHeight: 140)
                        .focused($isEditorFocused)
                        .background(Color.clear)
                }
                .background(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .cornerRadius(12)

                Picker(selection: $selectedAngerLevel, label: Text("Priority Level")) {
                    Text("Low").tag("Low")
                    Text("Medium").tag("Medium")
                    Text("High").tag("High")
                }
                .pickerStyle(SegmentedPickerStyle())
                .colorScheme(.dark)

                HStack(spacing: 10) {
                    Button(action: {
                        isEditorFocused = false
                        saveEntry()
                        dataStore.saveEntries()
                    }) {
                        Text("New Entry")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        dataStore.exportAllEntries()
                    }) {
                        Text("Export All")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.clear)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                            )
                            .cornerRadius(12)
                    }
                }

                List {
                    ForEach(dataStore.entries) { entry in
                        VStack(alignment: .leading) {
                            Text("\(entry.date, formatter: dateFormatter)")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(entry.text)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.86))
                            Text("Priority Level: \(entry.angerLevel)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.75))
                        }
                        .listRowBackground(Color.white.opacity(0.06))
                    }
                    .onDelete { indexSet in
                        deleteEntry(at: indexSet)
                        dataStore.saveEntries()
                    }
                }
                .listStyle(.plain)
                .background(Color.clear)
            }
            .sheet(isPresented: $showAdsAndAppFunctionality) {
                DiaryInfoSheetView(onConfirm: {
                    showAdsAndAppFunctionality = false
                })
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isEditorFocused = false
                    }
                }
            }
            .onTapGesture {
                isEditorFocused = false
            }
            .padding()
            .onDisappear {
                dataStore.saveEntries()
            }
        }
    }

    private func saveEntry() {
        guard !newText.isEmpty else { return }
        let newEntry = AngerEntry(date: Date(), text: newText, angerLevel: selectedAngerLevel)
        dataStore.entries.append(newEntry)
        newText = ""
    }

    private func deleteEntry(at offsets: IndexSet) {
        dataStore.entries.remove(atOffsets: offsets)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

struct DiaryView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryView(dataStore: DataStore())
    }
}
