//
//  GalleryScreen.swift
//  secondCamera
//
//  Created by Filip Šašala on 18/05/2023.
//

import SwiftUI
import SharedObject

extension URL: Identifiable {

    public var id: UUID { UUID() }

}

final class GalleryViewModel: ObservableObject {

    @SharedObject(C.dependencyContainer) var di: DependencyContainer
    @Published var images: [URL]

    var fileManager: FileManager { di.fileManager }

    init(gallery: Gallery) {
        self.images = []

        let urls = try? fileManager.getAllFiles(at: gallery.location)
        self.images = urls ?? []
    }

}

struct GalleryScreen: View {

    @ObservedObject var viewModel: GalleryViewModel

    @State private var presentedImage: URL?

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(spacing: 4), GridItem(spacing: 4), GridItem(spacing: 4)],
                spacing: 4
            ) {
                ForEach(viewModel.images, id: \.self) { url in
                    imageButton(url)
                }
            }
        }
        .fullScreenCover(item: $presentedImage, onDismiss: { presentedImage = nil }) {
            GalleryDetail(
                images: viewModel.images,
                selectedIndex: viewModel.images.firstIndex(of: $0) ?? 0
            )
        }
        .navigationTitle("\(viewModel.images.count) \((2..<5).contains(viewModel.images.count) ? "obrázky" : viewModel.images.count == 1 ? "obrázok" : "obrázkov")")
        .navigationBarTitleDisplayMode(.inline)
    }

    func imageButton(_ url: URL) -> some View {
        Button(action: {
            presentedImage = url
        }, label: {
            AsyncImage(url: url, content: {
                $0.resizable().aspectRatio(contentMode: .fill)
            }, placeholder: {
                Icon(.photo)
                    .foregroundColor(.accentColor)
                    .padding(32)
            })
        })
    }

}

struct GalleryDetail: UIViewControllerRepresentable {

    let images: [URL]
    let selectedIndex: Int

    func makeUIViewController(context: Context) -> some UIViewController {
        let galleryDetailController = GalleryDetailViewController(viewModel: GalleryDetailViewModel(
            images: images,
            selectedIndex: selectedIndex
        ))

        let navigation = UINavigationController(rootViewController: galleryDetailController)
        return navigation
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

}

struct GalleryScreen_Previews: PreviewProvider {

    static var previews: some View {
        GalleryScreen(viewModel: GalleryViewModel(gallery: Gallery(location: Location())))
    }

}
