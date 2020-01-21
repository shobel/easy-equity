//
//  StatsNewsPageViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 12/24/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit

class StatsNewsPageViewController: UIPageViewController {
    
    weak var pageDelegate: StatsNewsPageViewControllerDelegate?
    
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [
                self.newViewController(controllerId: "StatsVC"),
                self.newViewController(controllerId: "NewsVC"),
                self.newViewController(controllerId: "AdvancedVC"),
                self.newViewController(controllerId: "FinVC"),
                self.newViewController(controllerId: "EarningsVC"),
                self.newViewController(controllerId: "PredictionsVC"),
                self.newViewController(controllerId: "InfoVC"),
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        pageDelegate?.pageViewController(pageViewController: self, didUpdatePageIndex: orderedViewControllers.count)
    }
    
    private func newViewController(controllerId: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: controllerId)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension StatsNewsPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if let firstViewController = viewControllers?.first, let index = orderedViewControllers.firstIndex(of: firstViewController) {
            pageDelegate?.pageViewController(pageViewController: self, didUpdatePageIndex: index)
        }
    }
    
}

protocol StatsNewsPageViewControllerDelegate: class {
    
    func pageViewController(pageViewController: UIPageViewController,
                                    didUpdatePageCount count: Int)
    
    func pageViewController(pageViewController: StatsNewsPageViewController,
                                    didUpdatePageIndex index: Int)
    
}

extension StatsNewsPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController)
            else { return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController)
            else { return nil
        }
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        return orderedViewControllers[nextIndex]
    }
    
    //    func presentationCount(for pageViewController: UIPageViewController) -> Int {
    //        return orderedViewControllers.count
    //    }
    //
    //    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    //        guard let firstViewController = viewControllers?.first,
    //            let firstViewControllerIndex = orderedViewControllers.firstIndex(of: firstViewController) else {
    //                return 0
    //        }
    //        return firstViewControllerIndex
    //    }
}
