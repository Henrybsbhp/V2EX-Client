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
    
    CGFloat maxWidth = lineFrag.size.width;
    CGFloat imageWidth = MIN(maxWidth, bounds.size.width);
    bounds.size = CGSizeMake(imageWidth, imageWidth / bounds.size.width * bounds.size.height);
    return bounds;
}

@end
