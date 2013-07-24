//
//  DGTextView.m
//
//  Created by Denis Chaschin on 24.07.13.
//  Copyright (c) 2013 Denis Chaschin. All rights reserved.
//

#import "DGTextView.h"

static NSString *const kSelectedTextRange = @"selectedTextRange";

@implementation DGTextView{
    UIView *cursor_;
    CGFloat caretWidth_;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [self setup:self.frame];
    [self addObserver:self forKeyPath:kSelectedTextRange options:NSKeyValueObservingOptionNew context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:kSelectedTextRange];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}

- (void)setCursorColor:(UIColor *)cursorColor {
    cursor_.backgroundColor = cursorColor;
}

- (UIColor *)cursorColor {
    return cursor_.backgroundColor;
}

#pragma mark - Private Implementation

- (void)setup:(CGRect)frame {
    // init here
    // Set up cursor
    cursor_ = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 3.0f, frame.size.height)];
    [self addSubview:cursor_];
    [cursor_ setBackgroundColor:[UIColor colorWithRed:81.0f/255.0f green:106.0f/255.0f blue:237.0f/255.0f alpha:1.0f]];
    cursor_.hidden = NO;
}

- (void)updateCaretPosition {
    UITextRange *range = [self selectedTextRange];
    
    // Shows then cursor in editing mode but only if no text is selected.  If text is selected then the default handles are shown.
    cursor_.hidden = !range.empty;
    
    CGRect rect = [self caretRectForPosition:range.start];
    rect.size.width = caretWidth_;
    cursor_.frame = rect;
}

- (void)textDidChange {
    [self updateCaretPosition];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:kSelectedTextRange]) {
        [self updateCaretPosition];
    }
}

#pragma mark - Base Class Overrides

- (BOOL)becomeFirstResponder {
    cursor_.alpha = 1.0f;
    [self updateCaretPosition];
    
    [UIView animateWithDuration:0.5f
                          delay:0.6f
                        options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                         cursor_.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){}];
    
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    cursor_.hidden = YES;
    [self bringSubviewToFront:cursor_];
    return [super resignFirstResponder];
}

- (CGRect)caretRectForPosition:(UITextPosition *)position {
    CGRect rect = [super caretRectForPosition:position];
    caretWidth_ = rect.size.width;
    rect.size.width = 0.0f;
    return rect;
}

@end
