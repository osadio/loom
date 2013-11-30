//
//  NCIEditServerView.m
//  Tapestry
//
//  Created by Ira on 11/18/13.
//  Copyright (c) 2013 Truststix. All rights reserved.
//

#import "NCIEditServerView.h"
#import "NCIWebSocketConnector.h"

@interface NCIEditServerView()<UITextFieldDelegate>{
    UITextField *serverUrlEdit;
    UIButton *clearBtn;
    UIButton *goBtn;
    UIButton *refreshBtn;
}

@end

static int editServerInputHeigth = 40;
static float iconDim = 40;

@implementation NCIEditServerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        serverUrlEdit = [[UITextField alloc] initWithFrame:CGRectZero];
        serverUrlEdit.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
        serverUrlEdit.autocorrectionType = UITextAutocorrectionTypeNo;
        serverUrlEdit.autocapitalizationType = UITextAutocapitalizationTypeNone;
        serverUrlEdit.layer.borderColor = [UIColor grayColor].CGColor;
        serverUrlEdit.layer.borderWidth = 0.2;
        serverUrlEdit.placeholder = @"nci.ilabs.inca.infoblox.com:28080/clientsock.yaws";
        serverUrlEdit.text = [[NCIWebSocketConnector interlocutor] getTapestryUrl];
        serverUrlEdit.layer.cornerRadius = 10;
        serverUrlEdit.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        serverUrlEdit.delegate = self;
        serverUrlEdit.returnKeyType = UIReturnKeyGo;
        [serverUrlEdit addTarget:self action:@selector(didChangeText) forControlEvents:UIControlEventEditingChanged];
        UILabel *serverEditLeftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, editServerInputHeigth)];
        serverEditLeftView.backgroundColor =  [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
        serverEditLeftView.text = NSLocalizedString(@"Tapestry Server:   ws://", nil);
        serverEditLeftView.font = [UIFont boldSystemFontOfSize:16];
        serverEditLeftView.textColor = [UIColor blackColor];
        serverUrlEdit.leftView = serverEditLeftView;
        serverUrlEdit.leftViewMode = UITextFieldViewModeAlways;
        [self addSubview:serverUrlEdit];
        
        clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, iconDim, iconDim)];
        [clearBtn setImage:[UIImage imageNamed:@"clear_input"] forState:UIControlStateNormal];
        [clearBtn addTarget:self action:@selector(clearInput) forControlEvents:UIControlEventTouchUpInside];
        clearBtn.hidden = YES;
        serverUrlEdit.rightView = clearBtn;
        serverUrlEdit.rightViewMode =  UITextFieldViewModeAlways;
        
        goBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [goBtn setImage:[UIImage imageNamed:@"go"] forState:UIControlStateNormal];
        [goBtn  addTarget:self action:@selector(connectUrl) forControlEvents:UIControlEventTouchUpInside];
        goBtn.hidden = YES;
        [self addSubview:goBtn];
        
        refreshBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [refreshBtn setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateHighlighted];
        refreshBtn.hidden = YES;
        [self addSubview:refreshBtn];
        
        self.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *freeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelUrlChanges)];
        self.userInteractionEnabled =YES;
        [self addGestureRecognizer:freeTap];
    }
    return self;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"freeTap" object:self];
    textField.backgroundColor = [UIColor whiteColor];
    [self didChangeText];
    goBtn.hidden = NO;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    textField.backgroundColor =  [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
    clearBtn.hidden = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self connectUrl];
    return YES;
}

- (void)didChangeText{
    if (serverUrlEdit.text.length == 0){
        clearBtn.hidden = YES;
    } else {
        clearBtn.hidden = NO;
    }
}

- (void)clearInput{
    serverUrlEdit.text = @"";
    clearBtn.hidden = YES;
}

-(void)connectUrl{
    goBtn.hidden = YES;
    [[NCIWebSocketConnector interlocutor] newTapestryUrl:serverUrlEdit.text];
    [[NCIWebSocketConnector interlocutor] resetData];
    [serverUrlEdit resignFirstResponder];
}

-(void)cancelUrlChanges{
    goBtn.hidden = YES;
    serverUrlEdit.text = [[NCIWebSocketConnector interlocutor] getTapestryUrl];
    [serverUrlEdit resignFirstResponder];
}

- (void)layoutSubviews {
    goBtn.frame = CGRectMake( self.bounds.size.width - 70, 0, iconDim, iconDim);
    refreshBtn.frame = CGRectMake( self.bounds.size.width - 70, 0, iconDim, iconDim);
    serverUrlEdit.frame = CGRectMake(10, 0, self.bounds.size.width - 80, editServerInputHeigth);
}

@end
