import SwiftUI

struct ResultScreen: View {
    var appVM: AppViewModel
    @State private var resultVM = ResultViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                imageSection
                descriptionSection
                actionButtons
            }
            .padding()
        }
        .navigationTitle("Description")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .task(id: appVM.selectedImage) {
            if resultVM.description.isEmpty && !resultVM.isLoading {
                await resultVM.generateDescription(for: appVM.selectedImage)
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var imageSection: some View {
        if let image = appVM.selectedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 280)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        }
    }

    @ViewBuilder
    private var descriptionSection: some View {
        if resultVM.isLoading {
            VStack(spacing: 12) {
                ProgressView()
                    .controlSize(.large)
                Text("Analyzing image…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
        } else if let error = resultVM.errorMessage {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Text(error)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Retry") {
                    Task { await resultVM.generateDescription(for: appVM.selectedImage) }
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        } else if !resultVM.description.isEmpty {
            Text(resultVM.description)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                appVM.navigateToCamera()
            } label: {
                Label("Scan Another", systemImage: "camera.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button {
                appVM.goHome()
            } label: {
                Text("Back Home")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding(.top, 8)
    }
}
