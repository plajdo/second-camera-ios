//
//  GalleryDetailViewController.swift
//  secondCamera
//
//  Created by Filip Šašala on 18/05/2023.
//

import UIKit

final class GalleryDetailViewModel {

    let images: [URL]
    var selectedIndex: Int

    init(images: [URL], selectedIndex: Int) {
        self.images = images
        self.selectedIndex = selectedIndex
    }

}

final class GalleryDetailViewController: UIPageViewController {

    // MARK: - Variables

    private var previousPage = GalleryDetailPhotoViewController()
    private var mainPage = GalleryDetailPhotoViewController()
    private var nextPage = GalleryDetailPhotoViewController()

    // MARK: - Constants

    private let viewModel: GalleryDetailViewModel

    // MARK: - Initialization

    required init(viewModel: GalleryDetailViewModel) {
        self.viewModel = viewModel

        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)

        self.navigationItem.backButtonDisplayMode = .generic
        self.modalPresentationStyle = .currentContext
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        dataSource = self

        setupView()
        setPages(images: viewModel.images)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        /// transparent bottom bar
        if let scrollView = view.subviews.filter({ $0 is UIScrollView }).first,
           let pageControl = view.subviews.filter({ $0 is UIPageControl }).first {
            scrollView.frame = view.bounds
            view.bringSubviewToFront(pageControl)
        }
    }

}

// MARK: - Setup

private extension GalleryDetailViewController {

    func setupView() {
        setupAppearance()
    }

    func setupAppearance() {
        let appearance = UIPageControl.appearance(whenContainedInInstancesOf: [GalleryDetailViewController.self])
        appearance.currentPageIndicatorTintColor = .tintColor
        appearance.pageIndicatorTintColor = .systemBackground
        appearance.backgroundStyle = .prominent

        view.backgroundColor = .white

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Zatvoriť",
            primaryAction: UIAction { [weak self] _ in self?.dismiss(animated: true) }
        )

        navigationController?.hidesBarsOnTap = true
    }

}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate

extension GalleryDetailViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let currentController = viewController as? GalleryDetailPhotoViewController else {
            return nil
        }

        var index = currentController.currentIndex - 1
        if index < 0 {
            index = viewModel.images.count - 1
        }
        let url = viewModel.images[index]

        if currentController === mainPage {
            let page = previousPage
            page.setup(imageUrl: url, index: index)
            return page
        } else if currentController === nextPage {
            let page = mainPage
            page.setup(imageUrl: url, index: index)
            return page
        } else if currentController === previousPage {
            let page = nextPage
            page.setup(imageUrl: url, index: index)
            return page
        } else {
            return nil
        }
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let currentController = viewController as? GalleryDetailPhotoViewController else {
            return nil
        }

        let index = (currentController.currentIndex + 1) % viewModel.images.count
        let url = viewModel.images[index]

        if currentController === mainPage {
            let page = nextPage
            page.setup(imageUrl: url, index: index)
            return page
        } else if currentController === nextPage {
            let page = previousPage
            page.setup(imageUrl: url, index: index)
            return page
        } else if currentController === previousPage {
            let page = mainPage
            page.setup(imageUrl: url, index: index)
            return page
        } else {
            return nil
        }
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return viewModel.images.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return viewModel.selectedIndex
    }

}

// MARK: - Private

private extension GalleryDetailViewController {

    func setPages(images: [URL]) {
        let selected = viewModel.selectedIndex
        mainPage.setup(imageUrl: images[selected], index: selected)

        if images.count < 2 {
            dataSource = nil
        }

        setViewControllers([mainPage], direction: .forward, animated: false)
    }

}

// MARK: - Photo controller

final class GalleryDetailPhotoViewController: UIViewController {

    // MARK: - Components

    private let scrollView = UIScrollView()
    private let imageView = UIImageView()

    // MARK: - Variables

    private(set) var currentURL: URL?
    private(set) var currentIndex: Int = -1

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        setupView()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: animated)
    }

}

// MARK: - Public

extension GalleryDetailPhotoViewController {

    func setup(imageUrl: URL, index: Int) {
        currentIndex = index

        URLSession.shared.dataTask(with: imageUrl, completionHandler: { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? imageUrl.lastPathComponent)

            DispatchQueue.main.async() { [weak self] in
                self?.imageView.image = UIImage(data: data)
            }
        }).resume()
    }

}

// MARK: - Scroll View Delegate

extension GalleryDetailPhotoViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}

// MARK: - Setup

private extension GalleryDetailPhotoViewController {

    func setupView() {
        setupAppearance()
        addSubviews()
        setupConstraints()
        addGestureRecognizer()
    }

    func setupAppearance() {
        view.backgroundColor = .white

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .white

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: IconImage.photo.rawValue)
    }

    func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.9)
        ])

        let imageViewHeight = view.frame.width * 0.9

        scrollView.contentInset = UIEdgeInsets(
            top: view.center.y - (imageViewHeight / 1.5),
            left: 0,
            bottom: 0,
            right: 0
        )
    }

    func addGestureRecognizer() {
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
    }

}

// MARK: - Private

private extension GalleryDetailPhotoViewController {

    @objc func doubleTapped(_ recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let scale = CGRect(
                origin: recognizer.location(in: scrollView),
                size: CGSize(width: 100, height: 100)
            )
            scrollView.zoom(to: CGRect(
                x: scale.minX - scale.width / 2,
                y: scale.minY - scale.height / 2,
                width: scale.width,
                height: scale.height
            ), animated: true)
        }
    }

}
