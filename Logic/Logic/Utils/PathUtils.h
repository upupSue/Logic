//
//  PathUtils.h
//  Logic
//
//  Created by 方琼蔚 on 16/12/10.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#ifndef PathUtils_h
#define PathUtils_h

static inline NSString *localWorkspace(){
    return [NSString pathWithComponents:@[documentPath(),@"Logic"]];
}

static inline NSString *trashWorkspace(){
    return [NSString pathWithComponents:@[documentPath(),@"Trash"]];
}

static inline NSString *cloudWorkspace(){
    NSURL *ubiquityURL = [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil]URLByAppendingPathComponent:@"Documents"];
    return ubiquityURL.path;
}

#endif /* PathUtils_h */
