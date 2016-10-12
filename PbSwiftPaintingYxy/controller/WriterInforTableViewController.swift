//
//  WriterInforTableViewController.swift
//  PbSwiftPaintingLys
//  作家主页
//  Created by Maqiang on 16/2/16.
//  Copyright © 2016年 ProteanBear. All rights reserved.
//

import Foundation
import UIKit
import PbSwiftLibrary
import AVFoundation
import AVKit

class WriterInforTableViewController: UITableViewController,UINavigationControllerDelegate
{
    //记录简介最大高度
    let maxHeight:CGFloat=228.0
    //记录简介最小高度
    let minHeight:CGFloat=138.0
    //记录当前的高度
    var curHeight:CGFloat=228.0
    
    //data:记录临时数据
    var data:NSMutableDictionary?
    //fromView:记录当前选中的视图
    var fromView:UIView?
    
    //画家头像
    @IBOutlet weak var writerImageView: UIImageView!
    //设置按钮
    @IBOutlet var settingButton: UIButton!
    @IBAction func doWhenTapSetting(_ sender: UIButton) {
        self.fromView=nil
        self.performSegue(withIdentifier: "mainPageToSetting", sender: self)
    }
    @IBAction func doWhenTapInfo(_ sender: AnyObject)
    {
        self.fromView=nil
        self.performSegue(withIdentifier: "mainPageToWritorInfo", sender: self)
    }
    
    //载入后设置头像
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //设置初始位置
        self.automaticallyAdjustsScrollViewInsets=false
        
        //右侧顶部按钮
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(customView:self.settingButton)
        //中间空白按钮
        let button=UIButton(frame: CGRect(x: 0, y: 0, width: 180, height: 44))
        button.addTarget(self, action: #selector(WriterInforTableViewController.doWhenTapInfo(_:)), for: .touchUpInside)
        self.navigationItem.titleView=button
        
        //注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(WriterInforTableViewController.doWhenTapToView(_:)), name:NSNotification.Name(rawValue: "doWhenTapToView"), object: nil)
    }
    
    //在 ViewController 中设置 NavigationController 的代理为自己
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.navigationController?.delegate = self
    }
    
    //返回每行的高度
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return (indexPath.row==0) ? curHeight:(PbSystem.screenCurrentHeight-curHeight)
    }
    
    //点击时处理
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //点击第一行进入画家信息
        if((indexPath as NSIndexPath).row==0)
        {
            self.fromView=nil
            self.performSegue(withIdentifier: "mainPageToWritorInfo", sender: self)
        }
    }
    
    //切换信息高度转换
    fileprivate func changeInfoHeight(_ toShowMax:Bool)
    {
        let curShowMax=(curHeight>minHeight)
        if(toShowMax && curShowMax){return}
        if(!toShowMax && !curShowMax){return}
        
        curHeight=(toShowMax) ? maxHeight:minHeight
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
    }
    
    //设置数据
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //显示分页视图
        if("WriterInfoToPage"==segue.identifier)
        {
            let viewController:WriterInfoPageViewController=segue.destination as! WriterInfoPageViewController
            viewController.blockHandleInforHeight={(toShowMax:Bool)->Void in
                self.changeInfoHeight(toShowMax)
            }
        }
        //图集内容
        if("worksToContentWorks"==segue.identifier)
        {
            let viewController:ContentWorksColletionViewController=segue.destination as! ContentWorksColletionViewController
            viewController.data=self.data
            viewController.fromMain=true
        }
        //文本内容
        if("worksToContentText"==segue.identifier)
        {
            let viewController:ContentTextViewController=segue.destination as! ContentTextViewController
            viewController.articleId=(self.data!.object(forKey: "articleId") as! String)
        }
        //视频内容
        if("worksToContentVideo"==segue.identifier)
        {
            let viewController:AVPlayerViewController=segue.destination as! AVPlayerViewController
            if let link=((data?.object(forKey: "attachments") as! NSArray).object(at: 0) as! NSDictionary).object(forKey: "resourceLink")
            {
                let player=AVPlayer(url: URL(string:(PbDataAppController.instance.fullUrl(link as! String)))!)
                viewController.player=player
            }
        }
    }
    
    //跳转到指定的视图
    func doWhenTapToView(_ notification:Notification)
    {
        let nameDictionary=(notification as NSNotification).userInfo
        if(nameDictionary==nil){return}
        let toIdentifier=nameDictionary!["identifier"] as? String
        let data=nameDictionary!["data"]
        let fromView=nameDictionary!["fromView"]
        
        self.data=nil
        self.fromView=nil
        self.data=(data==nil) ?nil:(NSMutableDictionary(dictionary:(data as! NSDictionary)))
        self.fromView=(fromView == nil) ? nil:(fromView as! UIView)
        
        //界面跳转
        self.performSegue(withIdentifier: toIdentifier!, sender: self)
    }
    
    //自定义转场动画
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return (operation == .push && self.fromView != nil) ? MainPageTransAnimationPush():nil
    }
}

//自定义转场动画:进入
class MainPageTransAnimationPush:NSObject,UIViewControllerAnimatedTransitioning
{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! WriterInforTableViewController
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! ContentWorksColletionViewController
        let container = transitionContext.containerView
        
        if(fromVC.fromView == nil){return}
        if(fromVC.fromView!.isKind(of: PaintingCollectionCell.self))
        {
            let fromView=(fromVC.fromView as! PaintingCollectionCell)
            let toView=toVC.preImageView
            toView.image=fromView.imageView.image
            let snapshotView = UIImageView(image: fromView.imageView.image)
            snapshotView.frame = container.convert(fromView.imageView.frame, from: fromView)
            snapshotView.pbAutoSetContentMode(1, lowMode: .bottomLeft, overMode: .scaleAspectFill)
            snapshotView.clipsToBounds=true
            fromView.imageView.isHidden = true
            
            toVC.view.frame = transitionContext.finalFrame(for: toVC)
            toVC.view.alpha = 0
            
            let backView=UIView(frame: CGRect.zero)
            backView.translatesAutoresizingMaskIntoConstraints=false
            backView.backgroundColor=UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
            backView.layer.opacity=0
            container.addSubview(backView)
            container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[backView]-0-|", options:.alignAllLastBaseline, metrics:nil, views:["backView":backView]))
            container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[backView]-0-|", options:.alignAllLastBaseline, metrics:nil, views:["backView":backView]))
            
            container.addSubview(toVC.view)
            container.addSubview(snapshotView)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                
                snapshotView.frame = toView.frame
                backView.layer.opacity=1
                
                }) { (finish: Bool) -> Void in
                    
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                        
                        snapshotView.alpha=0
                        toVC.view.alpha = 1
                        
                        }, completion: { (finished) -> Void in
                            
                            fromView.imageView.isHidden = false
                            snapshotView.removeFromSuperview()
                            backView.removeFromSuperview()
                            
                            transitionContext.completeTransition(true)
                    })
            }
        }
    }
}

//自定义转场动画:返回
class MainPageTransAnimationPop:NSObject,UIViewControllerAnimatedTransitioning
{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! ContentWorksColletionViewController
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! WriterInforTableViewController
        let container = transitionContext.containerView
        
        if(toVC.fromView == nil){return}
        if(toVC.fromView!.isKind(of: PaintingCollectionCell.self))
        {
            let snapshotView = UIImageView(image: fromVC.preImageView.image)
            snapshotView.frame = container.convert(fromVC.preImageView.frame, from: fromVC.view)
            snapshotView.pbAutoSetContentMode(1, lowMode: .bottomLeft, overMode: .scaleAspectFill)
            snapshotView.clipsToBounds=true
            fromVC.preImageView.isHidden = true
            
            let toView=toVC.fromView as! PaintingCollectionCell
            toVC.view.frame = transitionContext.finalFrame(for: toVC)
            toView.isHidden = true
            
            container.insertSubview(toVC.view, belowSubview: fromVC.view)
            
            let backView=UIView(frame: CGRect.zero)
            backView.translatesAutoresizingMaskIntoConstraints=false
            backView.backgroundColor=UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
            backView.layer.opacity=0
            container.addSubview(backView)
            container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[backView]-0-|", options:.alignAllLastBaseline, metrics:nil, views:["backView":backView]))
            container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[backView]-0-|", options:.alignAllLastBaseline, metrics:nil, views:["backView":backView]))
            
            container.addSubview(snapshotView)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                
                snapshotView.alpha = 1
                backView.layer.opacity=1
                fromVC.view.alpha = 0
                
                }) { (finish: Bool) -> Void in
                    
                    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                        
                        snapshotView.frame = container.convert(toView.imageView.frame, from: toView)
                        backView.layer.opacity=0
                        
                        }, completion: { (finished) -> Void in
                            
                            toView.isHidden = false
                            snapshotView.removeFromSuperview()
                            backView.removeFromSuperview()
                            fromVC.preImageView.isHidden = false
                            
                            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    })
            }
        }
    }
}
