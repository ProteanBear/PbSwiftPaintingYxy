//
//  WriterVideoCollectionViewController.swift
//  PbSwiftPaintingLys
//
//  Created by Maqiang on 16/2/18.
//  Copyright © 2016年 ProteanBear. All rights reserved.
//

import Foundation
import UIKit
import PbSwiftLibrary

class WriterVideoCollectionViewController: PbUICollectionViewController
{
    //blockHandleInforHeight:处理信息显示高度
    var blockHandleInforHeight:((_ toShowMax:Bool)->Void)?
    
    //视图载入后载入数据
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //设置布局
        let margin:CGFloat=10.0
        let layout=UICollectionViewFlowLayout()
        let cellWidth=(PbSystem.screenWidth-margin*5)/2
        layout.itemSize=CGSize(width: cellWidth,height: cellWidth)
        layout.minimumLineSpacing=margin
        layout.minimumInteritemSpacing=margin
        layout.sectionInset=UIEdgeInsetsMake(34+margin, margin*2, margin, margin*2)
        layout.scrollDirection=UICollectionViewScrollDirection.vertical
        self.collectionView?.setCollectionViewLayout(layout, animated: false)
        
        //载入数据
        self.pbLoadData(.first)
        self.loadCollectionCell?.backgroundColor=UIColor.clear
    }
    
    //是否支持网格顶部刷新
    override func pbSupportHeaderRefresh() -> Bool
    {
        return false
    }
    
    //返回当前数据访问使用的链接标识
    override func pbKeyForDataLoad() -> String?
    {
        return "busiCmsArticle"
    }
    
    //返回当前数据访问使用的参数
    override func pbParamsForDataLoad(_ updateMode: PbDataUpdateMode) -> NSMutableDictionary?
    {
        return NSMutableDictionary(dictionary: ["sectionCode":"0002"])
    }
    
    //解析处理返回的数据
    override func pbResolveFromResponse(_ response: NSDictionary) -> AnyObject?
    {
        var dataList:NSArray?
        
        let successObj: AnyObject?=response.object(forKey: "success") as AnyObject?
        if(successObj != nil)
        {
            let success=successObj as! Bool
            if(success)
            {
                dataList=response.object(forKey: "list") as? NSArray
            }
            else
            {
                self.pbErrorForDataLoad(PbUIViewControllerErrorType.serverError, error:(response.object(forKey:"infor") as! String))
            }
        }
        
        return dataList
    }
    
    //返回指定位置的单元格标识
    override func pbIdentifierForCollectionView(_ indexPath: IndexPath, data: AnyObject?) -> String
    {
        return "WriterVideoCell"
    }
    
    //设置表格数据显示
    override func pbSetDataForCollectionView(_ cell: AnyObject, data: AnyObject?, photoRecord: PbDataPhotoRecord?, indexPath: IndexPath) -> AnyObject
    {
        let cell=cell as! WriterVideoCell
        
        cell.titleLabel.text=(data!.object(forKey: "articleTitle") as! String)
        
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
    
    //设置指示器的颜色
    override func pbUIRefreshActivityDefaultColor() -> UIColor
    {
        return UIColor.pbGrey(.level600)
    }
    
    //点击播放
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let data=self.collectionData?.object(at:indexPath.row)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"doWhenTapToView"), object: self, userInfo:["identifier":"worksToContentVideo","data":data!])
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        
        if(self.blockHandleInforHeight != nil)
        {
            if(scrollView.contentOffset.y>44)
            {
                self.blockHandleInforHeight!(false)
            }
            if(scrollView.contentOffset.y < (-20))
            {
                self.blockHandleInforHeight!(true)
            }
        }
    }
}
