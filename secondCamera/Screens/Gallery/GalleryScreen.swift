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
    @Published var redirected: Bool = false

    var fileManager: FileManager { di.fileManager }

    init(gallery: Gallery) {
        self.images = []

        switch gallery.location.type {
        case .album:
            UIApplication.shared.open(URL(string: "photos-redirect://\(gallery.location.name)")!)
            redirected = true

        case .folder:
            let urls = try? fileManager.getAllFiles(at: gallery.location)
            self.images = urls ?? []
        }
    }

    init(images: [URL]) {
        self.images = images
    }

}

struct GalleryScreen: View {

    @ObservedObject var viewModel: GalleryViewModel

    @State private var presentedImage: URL?

    var body: some View {
        if viewModel.redirected {
            Text("Presmerované do galérie")
        } else {
            mainContent
        }
    }

    private var mainContent: some View {
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
                $0.resizable().scaledToFill()
            }, placeholder: {
                Icon(.photo)
                    .foregroundColor(.accentColor)
                    .padding(32)
            })
        })
        .clipped()
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
        GalleryScreen(viewModel: GalleryViewModel(images: [
            URL(string: "https://picsum.photos/id/237/200/300")!,
            URL(string: "https://picsum.photos/id/238/200/300")!,
            URL(string: "https://picsum.photos/id/239/200/300")!,
            URL(string: "https://picsum.photos/id/240/200/300")!,
            URL(string: "https://picsum.photos/id/241/200/300")!
        ]))
    }

}
