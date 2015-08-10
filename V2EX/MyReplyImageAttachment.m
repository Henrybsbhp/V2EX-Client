//
//  MyReplyImageAttachment.m
//  
//
//  Created by St.Jimmy on 8/11/15.
//
//

#import "MyReplyImageAttachment.h"

@implementation MyReplyImageAttachment

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    CGRect bounds = [super attachmentBoundsForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
    
    static CGFloat maxWidth = 270;
    CGFloat imageWidth = MIN(maxWidth, bounds.size.width);
    bounds.size = CGSizeMake(imageWidth, imageWidth / bounds.size.width * bounds.size.height);
    return bounds;
}

@end
