//
//  HomeworkBannerViewController.swift
//  UIComponents
//
//  Created by ozgun on 21.01.2022.
//

import UIKit

class HomeworkBannerViewController: UIPageViewController {
    
    var controllers: [UIViewController] = []
    private var currentPageIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        controllers = setViewControllers()
        
        pageControl.currentPage = currentPageIndex
        setViewControllers([controllers[currentPageIndex]],
                           direction: .forward,
                           animated: true,
                           completion: nil)
        self.view.addSubview(pageControl)
        
        //MARK: - Homework automatic transition every 10 sec.
        
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.currentPageIndex = (self.currentPageIndex < self.controllers.count - 1) ? self.currentPageIndex + 1 : 0  // At the end of the array stars from the beginning
            self.setViewControllers([self.controllers[self.currentPageIndex]], direction: .forward, animated: true, completion: nil)
            self.pageControl.currentPage = self.currentPageIndex
        }
    }
    
    private lazy var pageControl: UIPageControl = {
        let pageControlWidth: CGFloat = 200
        let pageControlHeight: CGFloat = 50
        
        let frame = CGRect(x: (screenWidth - pageControlWidth) / 2,
                           y: screenHeight - 100,
                           width: pageControlWidth,
                           height: pageControlHeight)
        
        let pageControl = UIPageControl(frame: frame)
        pageControl.numberOfPages = controllers.count
        pageControl.backgroundColor = .lightGray
        pageControl.layer.cornerRadius = pageControlHeight / 2
        pageControl.currentPageIndicatorTintColor = .yellow
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
        return pageControl
    }()
    
    @objc func pageControlValueChanged(_ sender: UIPageControl) {
        let index = sender.currentPage
        let direction: UIPageViewController.NavigationDirection = currentPageIndex > index ? .reverse : .forward
        currentPageIndex = index
        setViewControllers([controllers[index]], direction: direction, animated: true, completion: nil)
    }
    
    //MARK: - Created 5 view controllers with different bg colors and tags

    func setViewControllers() -> [UIViewController] {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let firstViewControler = storyboard.instantiateViewController(withIdentifier: "sampleViewController")
        firstViewControler.view.tag = 0
        firstViewControler.view.backgroundColor = .red
        
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "sampleViewController")
        secondViewController.view.tag = 1
        secondViewController.view.backgroundColor = .yellow
        
        let thirdViewController = storyboard.instantiateViewController(withIdentifier: "sampleViewController")
        thirdViewController.view.tag = 2
        thirdViewController.view.backgroundColor = .green
        
        let forthViewController = storyboard.instantiateViewController(withIdentifier: "sampleViewController")
        forthViewController.view.tag = 3
        forthViewController.view.backgroundColor = .blue
        
        let fifthViewController = storyboard.instantiateViewController(withIdentifier: "sampleViewController")
        fifthViewController.view.tag = 4
        fifthViewController.view.backgroundColor = .cyan
        
        return [firstViewControler, secondViewController, thirdViewController, forthViewController, fifthViewController]
    }
}

// MARK: - PageController DataSource
extension HomeworkBannerViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = viewController.view.tag
        
        if index == 0 {
            return controllers[controllers.count - 1]
        } else {
            return controllers[index - 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = viewController.view.tag
        
        if index + 1 < controllers.count {
            return controllers[index + 1]
        } else {
            return controllers[0]
        }
    }
    
}

// MARK: - PageController Delegate
extension HomeworkBannerViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        guard let index = pageViewController.viewControllers?.first?.view.tag else { return }
        self.pageControl.currentPage = index
        self.currentPageIndex = index
    }
}
