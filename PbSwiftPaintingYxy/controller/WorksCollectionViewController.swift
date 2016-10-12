//
//  WorksCollectionViewController.swift
//  PbSwiftPaintingLys
//  画家作品网格视图
//  Created by Maqiang on 16/2/15.
//  Copyright © 2016年 ProteanBear. All rights reserved.
//

import Foundation
import UIKit
import PbSwiftLibrary

class WorksCollectionViewController:PbUICollectionViewController,UICollectionViewDelegateFlowLayout
{
    //记录时间分组后的数据
    var collectionDataGroup:NSMutableArray?
    var collectionDataTime:NSMutableArray?
    
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
        layout.sectionInset=UIEdgeInsetsMake(margin, margin*2, margin, margin*2)
        layout.scrollDirection=UICollectionViewScrollDirection.vertical
        self.collectionView?.setCollectionViewLayout(layout, animated: false)
        
        //载入数据
        self.pbLoadData(.first)
        self.loadCollectionCell?.backgroundColor=UIColor.clear
    }
    
    //pbSupportHeaderRefresh:是否支持表格顶部刷新
    override func pbSupportHeaderRefresh() -> Bool
    {
        return false
    }
    override func pbSupportFooterLoad() -> Bool
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
        return NSMutableDictionary(dictionary: ["sectionCode":"0000","limit":99])
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
                
                //解析为分组数据
                if(self.collectionDataGroup == nil)
                {
                    self.collectionDataGroup=NSMutableArray()
                    self.collectionDataTime=NSMutableArray()
                }
                self.collectionDataGroup?.removeAllObjects()
                self.collectionDataTime?.removeAllObjects()
                var date:String?=nil
                let array=NSMutableArray()
                for i in 0..<dataList!.count
                {
                    let data=dataList?.object(at: i) as! NSDictionary
                    let dateTime=(data.object(forKey: "articleTitleSub")as! String)
                    
                    if(date != nil
                        && date != dateTime)
                    {
                        self.collectionDataGroup?.add(NSArray(array:array))
                        self.collectionDataTime?.add(date!)
                        date=dateTime
                        array.removeAllObjects()
                    }
                    
                    if(date == nil)
                    {
                        date=dateTime
                    }
                    array.add(NSDictionary(dictionary:data))
                }
                if(date != nil)
                {
                    self.collectionDataGroup?.add(NSArray(array:array))
                    self.collectionDataTime?.add(date!)
                }
            }
            else
            {
                self.pbErrorForDataLoad(PbUIViewControllerErrorType.serverError, error:(response.object(forKey: "infor") as! String))
            }
        }
        
        return dataList
    }
    
    //返回指定位置的单元格标识
    override func pbIdentifierForCollectionView(_ indexPath: IndexPath, data: AnyObject?) -> String
    {
        return "PaintingCollectionCell"
    }
    
    //pbResolveDataInIndexPath:获取指定单元格位置的数据
    override func pbResolveDataInIndexPath(_ indexPath:IndexPath) -> AnyObject?
    {
        if(self.collectionDataGroup != nil)
        {
            let array=self.collectionDataGroup!.object(at: (indexPath as NSIndexPath).section) as! NSArray
            return array.object(at: (indexPath as NSIndexPath).row) as AnyObject?
        }
        return nil
    }
    
    //pbLoadCellInIndexPath:获取指定的载入指示器
    override func pbLoadCellInIndexPath(_ indexPath:IndexPath) -> UICollectionViewCell?
    {
        var result:UICollectionViewCell?
        
        if(self.collectionDataGroup != nil)
        {
            if(self.pbSupportFooterLoad()&&(indexPath as NSIndexPath).section==self.collectionDataGroup?.count)
            {
                self.collectionView?.register(PbUICollectionViewCellForLoad.self, forCellWithReuseIdentifier:loadCellIdentifier)
                result=self.collectionView?.dequeueReusableCell(withReuseIdentifier: loadCellIdentifier, for: indexPath)
                
                self.loadCollectionCell=result as? PbUICollectionViewCellForLoad
                if let color = self.pbSupportFooterLoadColor()
                {
                    self.loadCollectionCell?.setIndicatorTiniColor(color)
                }
                //                self.loadCollectionCell?.startLoadAnimating()
                return result!
            }
        }
        
        return nil
    }
    
    //设置表格数据显示
    override func pbSetDataForCollectionView(_ cell: AnyObject, data: AnyObject?, photoRecord: PbDataPhotoRecord?, indexPath: IndexPath) -> AnyObject
    {
        let cell=cell as! PaintingCollectionCell
        
        cell.titleLabel.text=(data!.object(forKey: "articleTitle") as! String)
        
        if(photoRecord != nil)
        {
            switch(photoRecord!.state)
            {
            case .new:
                self.pbAddPhotoTaskToQueue(indexPath, data: data)
                cell.imageView.image=nil
                break
            case .downloaded:
                cell.imageView.pbAnimation(photoRecord?.image, scale: 1, lowMode: .bottomLeft, overMode: .scaleAspectFill)
                break
            case .filtered:
                cell.imageView.pbAnimation(photoRecord?.image, scale: 1, lowMode: .bottomLeft, overMode: .scaleAspectFill)
                break
            case .failed:
                cell.imageView.image=nil
                break
            }
        }
        else
        {
            //设置默认图片
            cell.imageView.image=nil
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
    
    //点击网格
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let array=self.collectionDataGroup!.object(at: (indexPath as NSIndexPath).section) as! NSArray
        let data=NSMutableDictionary(dictionary:array.object(at: (indexPath as NSIndexPath).row) as! NSDictionary)
        let cell:PaintingCollectionCell=collectionView.cellForItem(at: indexPath) as! PaintingCollectionCell
        if let image=cell.imageView.image
        {
            data.setObject(image, forKey:"defaultImage" as NSCopying)
        }
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "doWhenTapToView"), object: self, userInfo:
            ["identifier":"worksToContentWorks","data":data,"fromView":cell])
    }
    
    //滚动修改顶部信息区域大小
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
    
    /*-----------------------开始：实现UICollectionViewDataSource*/
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        var result=1
        
        if(self.collectionDataTime != nil)
        {
            result=self.collectionDataTime!.count
            result=((self.pbSupportFooterLoad())
                && self.dataAdapter != nil
                && (!self.dataAdapter!.nextIsNull))
                ?(result+1)
                :result
        }
        
        return result
    }
    
    //collectionView:numberOfItemsInSection:返回每节网格内的网格数
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        var result=0
        
        if(self.collectionDataGroup != nil)
        {
            if(section != self.collectionDataGroup!.count)
            {
                let array=self.collectionDataGroup!.object(at: section) as! NSArray
                result=array.count
            }
            else
            {
                result=1
            }
        }
        else
        {
            result=super.collectionView(collectionView, numberOfItemsInSection:section)
        }
        
        return result
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSize(width: PbSystem.screenWidth,height: 34+(section==0 ? 34:0))
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        let result=self.collectionView?.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:"PaintingCollectionHeader", for: indexPath)
        if(result!.isKind(of: PaintingCollectionHeader.self)
            && self.collectionDataTime != nil)
        {
            let result=result as! PaintingCollectionHeader
            result.dateLabel.text=String(describing: self.collectionDataTime!.object(at: indexPath.section))
        }
        return result!
    }
    /*-----------------------结束：实现UICollectionViewDataSource*/
}
