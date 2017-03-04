//
//  ModelFile.h
//  ESuperVisionProject
//
//  Created by 石显军 on 16/2/24.
//  Copyright © 2016年 dhyt. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FileType)
{
    FileType_text = 0,
    FileType_image = 1,
    FileType_video = 2,
    FileType_Audio = 3,
    FileType_Word = 4,
    FileType_Tem = 5,
    FileType_PDF = 6,
    FileType_Exc = 9
};



@interface ModelFile : NSObject

/**
 *@ 文件类型  缓存文件用此类型
 *@ 0 文字 text
 *@ 1 图片
 *@ 2 视频
 *@ 3 音频
 *@ 5 模板
 */
@property (nonatomic, assign) FileType fileType;
@property (nonatomic, strong) NSString *type;



/**
 *@ 文件存储地址
 *@ 1 网络数据
 *@ 2 本地数据
 */
@property (nonatomic, assign) NSInteger fileAddressType;

/**
 *@ 图片
 */
//@property (nonatomic, strong) UIImage *image;

/**
 *@ 本地文件路径
 */
@property (nonatomic, strong) NSString *filePath;

/**
 *@ 网络文件路径
 */
@property (nonatomic, strong) NSString *mime;

/** 上传时间 */
@property (nonatomic, strong) NSString *insert_time;

/**
 *@ 文件名称
 */
@property (nonatomic, strong) NSString *name;

/**
 *@ 扩展
 */
@property (nonatomic, strong) NSString *extend;

/**
 *@ 标识
 */
@property (nonatomic, strong) NSString *key;

/** 模块 */
@property (nonatomic, assign) NSInteger module;

/**
 *@ 文字
 */
@property (nonatomic, strong) NSString *text;

/**
 *@ 模板
 */
@property (nonatomic, strong) NSString *strHtml;

/**
 *@ 任务文件 ID
 */
@property (nonatomic, strong) NSString *task_mime_id;

/**
 *@ 通知回复文件 ID
 */
@property (nonatomic, strong) NSString *extra_notice_mime_id;

/**
 *@ 施工方签字人员id(为null表示未签字)
 */
@property (nonatomic, strong) NSString *sign_sgf;

/**
 *@ 监理方签字人员id(为null表示未签字)
 */
@property (nonatomic, strong) NSString *sign_jlf;

/**
 *@ 上传人公司类型 (2、3 为施工方)
 */
@property (nonatomic, strong) NSString *unit_type;

/**
 *@ MP3 音频文件数据
 */
@property (nonatomic, strong) NSData *audioMp3Data;

#pragma mark - 日志 属性

/**
 *@ 日志文件ID
 */
@property (nonatomic, strong) NSString *user_log_mime_id;

#pragma mark - 通知属性
/**
 *@ 通知文件ID
 */
@property (nonatomic, strong) NSString *notice_mime_id;


/**
 *@ is_copy:是否复制（0否，1是）
 */
@property (nonatomic,assign) int is_copy;

/**
 *@ 变洽签添加图片 ID
 */
@property (nonatomic, strong) NSString *bqq_main_task_mime_id;
/**
 *@ 月度计价添加图片 ID
 */
@property (nonatomic, strong) NSString *monthly_price_main_task_mime_id;
@end
