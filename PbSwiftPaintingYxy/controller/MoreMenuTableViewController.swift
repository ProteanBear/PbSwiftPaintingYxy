//
//  MoreMenuTableViewController.swift
//  PbSwiftPaintingLys
//  更多菜单
//  Created by Maqiang on 16/2/16.
//  Copyright © 2016年 ProteanBear. All rights reserved.
//

import Foundation
import UIKit
import PbSwiftLibrary

//MoreMenuTableViewController:更多菜单
class MoreMenuTableViewController: CustomTableViewController
{
    //拨打电话
    @IBOutlet weak var phoneLabel: UILabel!
    //版本显示
    @IBOutlet weak var versionLabel: UILabel!
    //缓存容量
    @IBOutlet weak var cacheLabel: UILabel!
    
    //记录版本更新的链接
    var versionLink:String?
    
    //进入后检查最新版本、设置缓存容量
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets=false
        self.checkLastestVersion()
        self.cacheLabel.text=PbDataAppController.instance.sizeOfCacheDataInLocal()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return section==0 ? (64+34):34
    }
    
    //点击事件
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if((indexPath as NSIndexPath).section==0)
        {
            //收藏交易（拨打电话）
            if((indexPath as NSIndexPath).row==1)
            {
                if(self.phoneLabel.text=="暂无电话")
                {
                    let alert=UIAlertController.pbAlert("拨打电话",message:"对不起，目前没有联系电话")
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    let sheet=UIAlertController.pbSheet("拨打电话："+self.phoneLabel.text!, actions: [
                        UIAlertAction(title: "拨打", style: .default, handler: { (action) in
                            UIApplication.shared.openURL(URL(string:"tel://"+self.phoneLabel.text!)!)
                        })
                    ])
                    self.present(sheet, animated: true, completion: nil)
                }
            }
        }
        if((indexPath as NSIndexPath).section==1)
        {
            //清理缓存
            if((indexPath as NSIndexPath).row==0)
            {
                self.cacheLabel.text=PbDataAppController.instance.clearCacheDataInLocal()
            }
        }
        if((indexPath as NSIndexPath).section==2)
        {
            //更新版本
            if((indexPath as NSIndexPath).row==0)
            {
                if(self.versionLink != nil)
                {
                    let sheet=UIAlertController.pbSheet("更新版本："+self.versionLabel.text!,cancelLabel:"忽略", actions: [
                        UIAlertAction(title: "更新", style: .default, handler: { (action) in
                            UIApplication.shared.openURL(URL(string:(PbDataAppController.instance.fullUrl(self.versionLink!)))!)
                        })
                    ])
                    self.present(sheet, animated: true, completion: nil)
                }
                else
                {
                    self.checkLastestVersion()
                }
            }
        }
    }
    
    //点击检查更新
    func checkLastestVersion()
    {
        self.versionLabel.text="检查中..."
        PbDataAppController.instance.request("systemVersionLastest", params: NSDictionary(dictionary:["versionBuild":Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!]), callback: { (data, error, property) -> Void in
                var success=false
                if(data != nil && (data?.count)!>0)
                {
                    success=(data!.object(forKey: "success")! as AnyObject).boolValue
                }
                if(success)
                {
                    let needUpdate:Bool=(data!.object(forKey: "needUpdate")! as AnyObject).boolValue
                    if(needUpdate)
                    {
                        self.versionLabel.text=data?.object(forKey: "versionName") as? String
                        self.versionLink=data?.object(forKey: "versionLink") as? String
                    }
                    else
                    {
                        self.versionLabel.text="已是最新！"
                    }
                }
                else
                {
                    self.versionLabel.text="检查失败！"
                }
            }, getMode:.fromNet)
    }
}

//MenuFavoriteCollectionViewController:收藏作品
class MenuFavoriteCollectionViewController:CustomPbCollectionViewController
{
    //记录当前状态，0-正常、1-编辑模式
    var status=0
    //selectKeys:记录选中的标识
    var selectKeys=NSMutableArray()
    //记录当前数据
    var data:NSMutableDictionary?
    
    //载入视图后
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //设置操作菜单
        self.setRightBarButtonItems()
        
        //设置布局
        self.setCollectionLayout()
        
        //载入数据
        self.reloadFavoriteData()
    }
    
    //翻转后
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation)
    {
        self.setCollectionLayout()
    }
    
    //进入编辑模式
    func doWhenTapEditButton(_ button:UIButton)
    {
        self.selectKeys.removeAllObjects()
        self.status=1
        self.setRightBarButtonItems()
    }
    
    //删除选中的
    func doWhenTapRemoveButton(_ button:UIButton)
    {
        let sheet=UIAlertController.pbSheet("删除收藏？", actions: [
            UIAlertAction(title: "删除选中的", style: .default, handler: { (action) in
                PbDataUserController.instance.removeFavoritesWithArray(self.selectKeys)
                self.status=0
                self.reloadFavoriteData()
                self.setRightBarButtonItems()
            }),
            UIAlertAction(title: "退出编辑", style: .default, handler: { (action) in
                self.status=0
                self.reloadFavoriteData()
                self.setRightBarButtonItems()
            })
        ])
        self.present(sheet, animated: true, completion: nil)
    }
    
    //设置操作按钮
    fileprivate func setRightBarButtonItems()
    {
        //正常模式
        if(self.status==0)
        {
            let backView=UIButton(type:.custom)
            backView.setImage(UIImage(named:"icon_edit"), for: UIControlState())
            backView.frame=CGRect(x: 0, y: 0, width: 28, height: 28)
            backView.contentMode = .center
            backView.backgroundColor=UIColor(white:0, alpha:0.8)
            backView.layer.cornerRadius=14
            backView.layer.borderColor=UIColor.white.cgColor
            backView.layer.borderWidth=0.5
            backView.addTarget(self, action:#selector(MenuFavoriteCollectionViewController.doWhenTapEditButton(_:)), for:.touchUpInside)
            self.navigationItem.setRightBarButton(UIBarButtonItem(customView:backView), animated: true)
        }
        //编辑模式
        if(self.status==1)
        {
            let backView=UIButton(type:.custom)
            backView.setImage(UIImage(named:"icon_remove"), for: UIControlState())
            backView.frame=CGRect(x: 0, y: 0, width: 28, height: 28)
            backView.contentMode = .center
            backView.backgroundColor=UIColor(white:0, alpha:0.8)
            backView.layer.cornerRadius=14
            backView.layer.borderColor=UIColor.white.cgColor
            backView.layer.borderWidth=0.5
            backView.addTarget(self, action:#selector(MenuFavoriteCollectionViewController.doWhenTapRemoveButton(_:)), for:.touchUpInside)
            self.navigationItem.setRightBarButton(UIBarButtonItem(customView:backView), animated: true)
        }
    }
    
    //载入收藏数据
    fileprivate func reloadFavoriteData()
    {
        self.collectionData=NSMutableArray()
        if let userFavorite=PbDataUserController.instance.userFavorite
        {
            for data in userFavorite.objectEnumerator()
            {
                self.collectionData?.add(data)
            }
        }
        self.photoData.removeAll()
        self.collectionView?.reloadData()
    }
    
    //设置布局
    fileprivate func setCollectionLayout()
    {
        let margin:CGFloat=10.0
        let layout=UICollectionViewFlowLayout()
        let cellWidth=(PbSystem.screenWidth-margin*3)/2
        layout.itemSize=CGSize(width: cellWidth,height: cellWidth)
        layout.minimumLineSpacing=margin
        layout.minimumInteritemSpacing=margin
        layout.sectionInset=UIEdgeInsetsMake(margin, margin, margin, margin)
        layout.scrollDirection=UICollectionViewScrollDirection.vertical
        self.collectionView?.setCollectionViewLayout(layout, animated: true)
    }
    
    //返回指定位置的单元格标识
    override func pbIdentifierForCollectionView(_ indexPath: IndexPath, data: AnyObject?) -> String
    {
        return "WorksFavoriteCell"
    }
    
    //设置表格数据显示
    override func pbSetDataForCollectionView(_ cell: AnyObject, data: AnyObject?, photoRecord: PbDataPhotoRecord?, indexPath: IndexPath) -> AnyObject
    {
        let cell=cell as! WorksFavoriteCell
        
        cell.titleLabel.text=" "+(data!.object(forKey: "articleTitle") as! String)
        cell.cellSelect(false)
        
        if(photoRecord != nil)
        {
            switch(photoRecord!.state)
            {
            case .new:
                self.pbAddPhotoTaskToQueue(indexPath, data: data)
                cell.titleImageView.image=nil
            case .downloaded:
                cell.titleImageView.pbAnimation(photoRecord?.image, scale: 1, lowMode: .scaleAspectFill, overMode: .scaleAspectFill)
            case .failed:
                cell.titleImageView.image=nil
            default:
                cell.titleImageView.image=nil
            }
        }
        else
        {
            //设置默认图片
            cell.titleImageView.image=nil
        }
        
        return cell
    }
    
    //pbPhotoUrlInIndexPath:返回单元格中的网络图片链接（不设置则无网络图片下载任务）
    override func pbPhotoUrlInIndexPath(_ indexPath: IndexPath, data: AnyObject?) -> String?
    {
        if(data==nil){return ""}
        
        let attches:NSArray?=(data as! NSDictionary).object(forKey: "attachments") as? NSArray
        if(attches==nil || attches!.count<1){return ""}
        
        return (attches!.object(at: 0) as! NSDictionary).object(forKey: "resourceThumb") as? String
    }
    
    //点击处理
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath)
    {
        let data=self.collectionData?.object(at:indexPath.row) as? NSDictionary
        
        if(self.status==0)
        {
            self.data=NSMutableDictionary(dictionary:data!)
            self.performSegue(withIdentifier: "favoriteToContentImage", sender: self)
        }
        if(self.status==1)
        {
            let cell:WorksFavoriteCell=self.collectionView!.cellForItem(at: indexPath) as! WorksFavoriteCell
            let selected=cell.selectedImageView.isHidden
            cell.cellSelect(selected)
            if let id=data?.object(forKey: "articleId")
            {
                if(selected)
                {
                    self.selectKeys.add(id)
                }
                else
                {
                    self.selectKeys.remove(id)
                }
            }
        }
    }
    
    //设置数据
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //图集内容
        if("favoriteToContentImage"==segue.identifier)
        {
            let viewController:ContentWorksColletionViewController=segue.destination as! ContentWorksColletionViewController
            viewController.data=self.data
            viewController.fromMain=false
            viewController.blockWhenBack={() -> Void in
                self.reloadFavoriteData()
            }
        }
    }
    
    override func pbSupportHeaderRefresh() -> Bool
    {
        return false
    }
    
    override func pbSupportFooterLoad() -> Bool
    {
        return false
    }
}

//MenuTopicTableViewController:推荐应用
class MenuTopicTableViewController:CustomTableViewController,UMSocialUIDelegate
{
    let urls=["http://125.67.237.140:81/zhmj/download/zhmj.html","http://125.67.237.140:81/zhmj/phone/welcome_paint_wyl.html","http://125.67.237.140:81/zhmj/download/lys.html"]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets=false
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return section==0 ? (64+34):34
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if((indexPath as NSIndexPath).section==0)
        {
            //二维码
            if((indexPath as NSIndexPath).row==0)
            {
                self.performSegue(withIdentifier: "topicToQrcode", sender: self)
            }
            //分享给好友
            if((indexPath as NSIndexPath).row==1)
            {
                let shareText="下载画家《"+(Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName")as! String)+"》的应用"
                
                UMSocialData.default().extConfig.wechatSessionData.urlResource.setResourceType(UMSocialUrlResourceTypeImage, url:UMKeyData.url)
                UMSocialData.default().extConfig.wechatTimelineData.urlResource.setResourceType(UMSocialUrlResourceTypeImage, url:UMKeyData.url)
                UMSocialData.default().extConfig.wechatFavoriteData.urlResource.setResourceType(UMSocialUrlResourceTypeImage, url:UMKeyData.url)
                UMSocialData.default().extConfig.qqData.urlResource.setResourceType(UMSocialUrlResourceTypeImage, url:UMKeyData.url)
                
                UMSocialSnsService.presentSnsIconSheetView(self, appKey:UMKeyData.appKey, shareText: shareText, shareImage: UIImage(named:"icon120.png"), shareToSnsNames:UMKeyData.shareToSnsNames, delegate:self)
            }
        }
        if((indexPath as NSIndexPath).section==1)
        {
            UIApplication.shared.openURL(URL(string:self.urls[(indexPath as NSIndexPath).row])!)
        }
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
}

//MenuFeedbackTableViewController:意见反馈
class MenuFeedbackTableViewController:CustomTableViewController
{
    //反馈内容
    @IBOutlet weak var contentTextView: UITextView!
    //反馈邮箱
    @IBOutlet weak var emailTextField: UITextField!
    //发送按钮
    @IBOutlet weak var sendButton: UIButton!
    
    //发送反馈
    @IBAction func doWhenTapSendButton(_ sender: UIButton)
    {
        self.sendButton.isEnabled=false
        
        self.contentTextView.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
        
        if(self.contentTextView.text=="")
        {
            self.pbMsgTip("反馈内容不能为空！", dismissAfterSecond:3, position:.top)
            self.contentTextView.becomeFirstResponder()
            self.sendButton.isEnabled=true
            return
        }
        if(self.emailTextField.text=="")
        {
            self.pbMsgTip("邮箱不能为空！", dismissAfterSecond:3, position:.top)
            self.emailTextField.becomeFirstResponder()
            self.sendButton.isEnabled=true
            return
        }
        
        PbDataAppController.instance.request("busiFeedback", params: NSDictionary(dictionary:["feedbackContent":self.contentTextView.text!,"feedbackEmail":self.emailTextField.text!]), callback: { (data, error, property) -> Void in
            
                var success=false
                if(data != nil && (data?.count)!>0)
                {
                    success=(data!.object(forKey: "success")! as AnyObject).boolValue
                }
            
                self.sendButton.isEnabled=true
                self.pbMsgTip(success ?"提交反馈成功!":"提交反馈失败!", dismissAfterSecond:3, position:.top)
            
            }, getMode: .fromNet)
    }
    
    //载入视图后
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets=false
        
        //选中内容输入
        self.contentTextView.becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return section==0 ? (64+34):34
    }
}

//MenuAboutViewController:关于应用
class MenuAboutViewController:CustomViewController
{
    @IBOutlet weak var backImageView: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.backImageView.image=UIImage(named:"main_bg")
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.backImageView.image=nil
    }
}

//QrcodeViewController:二维码
class QrcodeViewController:CustomViewController
{
    @IBOutlet weak var backImageView: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.backImageView.image=UIImage(named:"main_bg")
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.backImageView.image=nil
    }
}

//WriterInfoViewController:作者信息
class WriterInfoViewController:CustomViewController
{
}
