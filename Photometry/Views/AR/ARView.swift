import SwiftUI

struct ModelView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ARQuickLookController(
            modelUrl: url) {
                dismiss()
            }
    }
}

#Preview {
    let mockModelStorage: ModelStorage = .mock
    let url = mockModelStorage.urls[0]
    
    ModelView(url: url)
}
