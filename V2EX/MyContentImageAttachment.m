//
//  MyImageAttachment.m
//  
//
//  Created by St.Jimmy on 8/10/15.
//
//

#import "MyContentImageAttachment.h"

@implementation MyContentImageAttachment

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    CGRect bounds = [super attachmentBoundsForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
    
    static CGFloat maxWidth = 304;
    CGFloat imageWidth = MIN(maxWidth, bounds.size.width);
    bounds.size = CGSizeMake(imageWidth, imageWidth / bounds.size.width * bounds.size.height);
    return bounds;
}


@end
