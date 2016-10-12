//
//  ContentWorksColletionViewController.swift
//  PbSwiftPaintingLys
//
//  Created by Maqiang on 16/2/20.
//  Copyright © 2016年 ProteanBear. All rights reserved.
//

import Foundation
import UIKit
import PbSwiftLibrary

//ContentWorksDetailViewController:作品详情底部视图
class ContentWorksDetailViewController:UIViewController
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var summaryTextView: UITextView!
}

//ContentWorksColletionViewController:作品网格视图
class ContentWorksColletionViewController:PbUICollectionViewController,UMSocialUIDelegate,UIActionSheetDelegate,UINavigationControllerDelegate
{
    @IBOutlet var downloadButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var favoriteButton: UIButton!
    
    //detailViewController:记录详细视图
    var detailViewController:ContentWorksDetailViewController?
    //defaultImage:默认图片
    var defaultImage:UIImage?
    //status:记录当前的模式，0-正常、1-隐藏
    var status=0
    //blockWhenBack:回退时的调用
    var blockWhenBack:(()->Void)?
    //preImageView:过渡动画使用视图
    var preImageView=UIImageView(frame:CGRect(x: 0, y: 0,width: (PbSystem.screenWidth-100)/2,height: (PbSystem.screenWidth-100)/2))
    //fromMain:记录是否来自主分页视图
    var fromMain=true
    //data:记录数据
    var data:NSMutableDictionary?{
        didSet{
            if(self.data==nil){return}
            
            self.collectionData=NSMutableArray(array:(self.data!.object(forKey: "attachments") as! Array<AnyObject>))
            self.defaultImage=self.data?.object(forKey: "defaultImage") as? UIImage
            if(self.defaultImage != nil)
            {
                self.defaultImage=self.defaultImage!.copy() as? UIImage
                self.data?.removeObject(forKey: "defaultImage")
            }
            self.collectionView!.reloadData()
            
            if(self.detailViewController != nil)
            {
                self.detailViewController?.titleLabel.text=(self.data!.object(forKey: "articleTitle") as! String)
                self.detailViewController?.summaryTextView.text=(self.data!.object(forKey: "articleSummary") as! String)
                
                let id=(self.data!.object(forKey: "articleId") as! String)
                self.favoriteButton.isSelected=PbDataUserController.instance.isFavorite(id)
            }
        }
    }
    
    //视图初始化
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //设置网格布局
        self.automaticallyAdjustsScrollViewInsets=false
        self.collectionView!.backgroundColor=UIColor.pbGrey(.level600)
        self.setCollectionViewLayout()
        self.setBarBackItem()
        self.setBarRightItems()
        
        //增加过渡预览视图
        self.preImageView.center=self.view.center
        self.preImageView.contentMode = .scaleAspectFill
        self.view.addSubview(self.preImageView)
        self.view.bringSubview(toFront: self.collectionView!)
        
        //增加底部显示
        self.detailViewController=self.storyboard?.instantiateViewController(withIdentifier: "ContentWorksInforView") as? ContentWorksDetailViewController
        self.detailViewController!.view.translatesAutoresizingMaskIntoConstraints=false
        self.view.addSubview(self.detailViewController!.view)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[detailView(==120)]-0-|", options: .alignAllLastBaseline, metrics:nil, views:["detailView":self.detailViewController!.view]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[detailView]-0-|", options: .alignAllLastBaseline, metrics:nil, views:["detailView":self.detailViewController!.view]))
    }
    
    //在 ViewController 中设置 NavigationController 的代理为自己
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.navigationController?.delegate = self
    }
    
    //退出时调用
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if(self.blockWhenBack != nil)
        {
            self.blockWhenBack!()
        }
    }
    
    //翻转后处理
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation)
    {
        self.setCollectionViewLayout()
    }
    
    //点击关闭按钮
    func doWhenTapCloseButton(_ sender:UIButton)
    {
        (self.transitioningDelegate as! UIViewController).dismiss(animated: true, completion: nil)
    }
    
    //点击屏幕改变模式
    @IBAction func doWhenTapView(_ sender: UITapGestureRecognizer)
    {
        self.navigationController?.setNavigationBarHidden(self.status==0, animated: true)
        
        UIView.animate(withDuration: 0.4, delay:0, options:UIViewAnimationOptions(), animations: { () -> Void in
            
            self.detailViewController!.view.layer.opacity=(self.status==0) ?0:1
            
            }) { (finished) -> Void in
                if(finished)
                {
                    for cell in self.collectionView!.visibleCells
                    {
                        let cell=cell as! ContentWorksCell
                        cell.setContentImageScale()
                        cell.contentImageView?.contentMode=(self.status==0) ? .scaleAspectFit:.scaleAspectFill
                        cell.setContentImageSize(self.sizeOfView(self.status==0 ? 1:0))
                    }
                    self.status=(self.status==0) ?1:0
                    self.setCollectionViewLayout()
                }
        }
    }
    
    //返回指定位置的单元格标识
    override func pbIdentifierForCollectionView(_ indexPath: IndexPath, data: AnyObject?) -> String
    {
        return "ContentWorksCell"
    }
    
    //设置表格数据显示
    override func pbSetDataForCollectionView(_ cell: AnyObject, data: AnyObject?, photoRecord: PbDataPhotoRecord?, indexPath: IndexPath) -> AnyObject
    {
        let cell=cell as! ContentWorksCell
        
        cell.setContentImageSize(self.sizeOfView(0))
        
        if(photoRecord != nil)
        {
            switch(photoRecord!.state)
            {
            case .new:
                self.pbAddPhotoTaskToQueue(indexPath, data: data)
                cell.contentImageView!.image=(self.defaultImage != nil) ? self.defaultImage:nil
            case .downloaded:
                cell.contentImageView!.pbAnimation(photoRecord?.image, scale: 1, lowMode: .scaleAspectFill, overMode: .scaleAspectFill)
            case .failed:
                cell.contentImageView!.image=(self.defaultImage != nil) ? self.defaultImage:nil
            default:
                cell.contentImageView!.image=(self.defaultImage != nil) ? self.defaultImage:nil
            }
        }
        else
        {
            //设置默认图片
            cell.contentImageView!.image=(self.defaultImage != nil) ? self.defaultImage:nil
        }
        
        return cell
    }
    
    //pbPhotoKeyInIndexPath:返回单元格中的网络图片标识（不设置则无网络图片下载任务）
    override func pbPhotoKeyInIndexPath(_ indexPath: IndexPath) -> String?
    {
        return "resourceMiddle"
    }
    
    //setCollectionViewLayout:设置布局
    fileprivate func setCollectionViewLayout()
    {
        let layout=UICollectionViewFlowLayout()
        layout.itemSize=self.sizeOfView(self.status)
        layout.minimumLineSpacing=0
        layout.minimumInteritemSpacing=0
        layout.sectionInset=UIEdgeInsetsMake(0,0,0,0)
        layout.scrollDirection=UICollectionViewScrollDirection.horizontal
        self.collectionView!.setCollectionViewLayout(layout, animated: true)
    }
    
    //sizeOfView:返回视图大小
    fileprivate func sizeOfView(_ status:Int) -> CGSize
    {
        return CGSize(width: self.collectionView!.frame.size.width,height: self.collectionView!.frame.size.height)
    }
    
    /*----------开始：实现UMSocialUIDelegate委托*/
    func didFinishGetUMSocialData(inViewController response: UMSocialResponseEntity!)
    {
        if((response) != nil)
        {
            if(response.responseCode==UMSResponseCodeSuccess)
            {
                self.pbMsgTip("分享成功！", dismissAfterSecond: 0.5, position: .bottom)
            }
            else
            {
                self.pbMsgTip("出现错误："+UMKeyData.errorDictionary[response.responseCode.rawValue.description]!, dismissAfterSecond: 0.5, position: .bottom)
            }
        }
        else
        {
            self.pbMsgTip("分享失败！", dismissAfterSecond: 0.5, position: .bottom)
        }
    }
    /*----------结束：实现UMSocialUIDelegate委托*/
    
    //自定义转场动画
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return (operation == .pop && self.fromMain) ? MainPageTransAnimationPop():nil
    }
    
    func setBarRightItems()
    {
        self.navigationItem.rightBarButtonItems=[UIBarButtonItem(customView:self.favoriteButton),UIBarButtonItem(customView:self.shareButton),UIBarButtonItem(customView:self.downloadButton)]
    }
    
    func setBarBackItem()
    {
        //设置返回按钮
        let backView=UIButton(type:.custom)
        backView.setImage(UIImage(named:"icon_left"), for: UIControlState())
        backView.frame=CGRect(x: 0, y: 0, width: 28, height: 28)
        backView.contentMode = .center
        backView.backgroundColor=UIColor(white:0, alpha:0.8)
        backView.layer.cornerRadius=14
        backView.layer.borderColor=UIColor.white.cgColor
        backView.layer.borderWidth=1
        backView.addTarget(self, action:#selector(ContentWorksColletionViewController.popViewController), for:.touchUpInside)
        self.navigationItem.leftBarButtonItem=UIBarButtonItem(customView:backView)
    }
    
    func popViewController()
    {
        _=self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doWhenTapShareButton(_ sender:UIButton)
    {
        var resourceLink:String?
        var image:UIImage?
        for indexPath in self.collectionView!.indexPathsForVisibleItems
        {
            resourceLink=(self.collectionData?.object(at:indexPath.row) as! NSDictionary).object(forKey: "resourceMiddle") as? String
            
            try? image=UIImage(data:Data(contentsOf:URL(string:resourceLink!)!))
        }
        
        UMSocialData.default().extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeImage
        UMSocialData.default().extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeImage
        UMSocialData.default().extConfig.wechatFavoriteData.wxMessageType = UMSocialWXMessageTypeImage
        UMSocialData.default().extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage
        
        UMSocialSnsService.presentSnsIconSheetView(self, appKey:UMKeyData.appKey, shareText: nil, shareImage:image, shareToSnsNames:UMKeyData.shareToSnsNames, delegate:self)
    }
    
    @IBAction func doWhenTapFavoriteButton(_ sender:UIButton)
    {
        let id=(self.data!.object(forKey: "articleId")as! String)
        sender.isSelected ? PbDataUserController.instance.removeFavorite(id):PbDataUserController.instance.addFavorite(self.data!, id: id)
        sender.isSelected=PbDataUserController.instance.isFavorite(id)
        self.pbMsgTip(sender.isSelected ?"收藏成功！":"已取消收藏！", dismissAfterSecond: 0.5, position: .bottom)
    }
    
    @IBAction func doWhenTapDownloadButton(_ sender:UIButton)
    {
        let sheet=UIAlertController.pbSheet("原图较大，确定下载到相册么？", actions:[
            UIAlertAction(title: "保存", style: .default, handler: { (action) in
                
                var resourceLink:String?
                var image:UIImage?
                for indexPath in self.collectionView!.indexPathsForVisibleItems
                {
                    resourceLink=(self.collectionData?.object(at:indexPath.row) as! NSDictionary).object(forKey: "resourceLink") as? String
                    image=UIImage(data:NSData(contentsOf:URL(string:resourceLink!)!)! as Data)
                }
                
                if(image != nil)
                {
                    UIImageWriteToSavedPhotosAlbum(image!,self, #selector(ContentWorksColletionViewController.image(_:didFinishSavingWithError:contextInfo:)),nil)
                }
                else
                {
                    self.pbMsgTip("图片下载失败！", dismissAfterSecond: 1, position: .bottom)
                }
                
            })
        ])
        self.present(sheet, animated: true, completion: nil)
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject)
    {
        self.pbMsgTip(error==nil ? "图片保存成功到相册！":"图片保存失败！", dismissAfterSecond: 1, position: .bottom)
    }
}
