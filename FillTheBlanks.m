//
//  FillTheBlanks.m
//  Evaluator
//
//  Created by Joseph caxton-Idowu on 30/10/2010.
//  Copyright 2010 caxtonidowu. All rights reserved.
//

#import "FillTheBlanks.h"
#import "TransparentToolBar.h"


static NSString *kViewKey = @"viewKey";

@implementation FillTheBlanks

@synthesize QuestionTemplate, SelectedTopic; //QuestionHeaderBox; //Search;  //QuestionItemBox
@synthesize  fileList, FileListTable, DirLocation,SFileName;
@synthesize  SFileName_Edit,QItem_Edit,QItem_View;
@synthesize AnswerObjects,Answer1,Answer2,Answer3,Answer4,Answer5,AnswerControls,ShowAnswer,RemoveContinueButton,Specialflag,Continue,FromClientAnswer;

static UIWebView *QuestionHeaderBox = nil;
#pragma mark -
#pragma mark View lifecycle

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 470



- (void)viewDidLoad {
    [super viewDidLoad];
	
    //To fix ios7 extending edges
    if([UIViewController instancesRespondToSelector:@selector(edgesForExtendedLayout)]){
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    

	QuestionHeaderBox =[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 300)];
	QuestionHeaderBox.scalesPageToFit = YES;
	
	self.FileListTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 160, SCREEN_WIDTH, SCREEN_HEIGHT - 170) style:UITableViewStyleGrouped];
	FileListTable.delegate = self;
	FileListTable.dataSource = self;
	//FileListTable.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    
    [self.FileListTable setBackgroundView:nil];
    NSString *BackImagePath = [[NSBundle mainBundle] pathForResource:@"back320x450" ofType:@"png"];
	UIImage *BackImage = [[UIImage alloc] initWithContentsOfFile:BackImagePath];
    self.FileListTable.backgroundColor = [UIColor colorWithPatternImage:BackImage];

	
	// Now I have added 1000 pdfs to the bundle. App is now ver slow
	// I don't need this to go live, it is just for admin only so i comment out CheckExistingFiles
	//CheckExistingFiles *ExistingFiles = [[CheckExistingFiles alloc]init];
	//NSArray *lists = ExistingFiles.ListofPdfsNotInDataBase;

	//self.fileList = lists;  
	
	//if ([fileList count ]  > 0) {
		
	//	NSString *FullFileName = [NSString stringWithFormat:@"%@",[fileList objectAtIndex:0]];
	//	[self setSFileName:[FullFileName lastPathComponent]];
		
		
	//}
	
	
	if (QItem_Edit != nil || QItem_View != nil) {
		// this means we are not in edit mode. we are in create mode.
		
		if (QItem_Edit) {
			
			NSString *result = [NSString stringWithFormat:@"%@",[QItem_Edit Question]];
			SFileName_Edit = result;
		
			UIBarButtonItem *NextButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style: UIBarButtonItemStyleBordered target:self action:@selector(Edit:)];
			self.navigationItem.rightBarButtonItem = NextButton;
		
		
		
		}
		
		else
		{
			
			
			CGRect frame = CGRectMake(5, 5, 250, 30);
			self.Answer1 =[[UITextField alloc] initWithFrame:frame];
			self.Answer2 =[[UITextField alloc] initWithFrame:frame];
			self.Answer3 =[[UITextField alloc] initWithFrame:frame];
			self.Answer4 =[[UITextField alloc] initWithFrame:frame];
			self.Answer5 =[[UITextField alloc] initWithFrame:frame];
			
			self.AnswerControls = [NSArray arrayWithObjects:
								   [NSDictionary dictionaryWithObjectsAndKeys:
									self.Answer1,kViewKey,nil],
								   
								   [NSDictionary dictionaryWithObjectsAndKeys:
									self.Answer2,kViewKey,nil],
								   
								   [NSDictionary dictionaryWithObjectsAndKeys:
									self.Answer3,kViewKey,nil],
								   
								   [NSDictionary dictionaryWithObjectsAndKeys:
									self.Answer4,kViewKey,nil],
								   
								   [NSDictionary dictionaryWithObjectsAndKeys:
									self.Answer5,kViewKey,nil],
								   
								   nil];
			
			NSString *result = [NSString stringWithFormat:@"%@",[QItem_View Question]];
			SFileName_Edit = result;
			
			AnswerObjects=  [[NSMutableArray alloc] initWithArray:[[QItem_View Answers1] allObjects]];
			
            if(!ShowAnswer){
            // create a toolbar where we can place some buttons
            TransparentToolBar* toolbar = [[TransparentToolBar alloc]
                                           initWithFrame:CGRectMake(250, 0, 200, 45)];
            
            
            
            // create an array for the buttons
            NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
            
            UIBarButtonItem *SendSupportMail = [[UIBarButtonItem alloc] initWithTitle:@"Report Problem" style: UIBarButtonItemStyleBordered target:self action:@selector(ReportProblem:)];
            
            [buttons addObject:SendSupportMail];
            
            
            // create a spacer between the buttons
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil
                                       action:nil];
            [buttons addObject:spacer];
            
            
            
                
                
                UIBarButtonItem *EndTestnow = [[UIBarButtonItem alloc] initWithTitle:@"Stop Test" style: UIBarButtonItemStyleBordered target:self action:@selector(StopTest:)];
                
                
                [buttons addObject:EndTestnow];
            
            
            
            [toolbar setItems:buttons animated:NO];
            
            // place the toolbar into the navigation bar
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                      initWithCustomView:toolbar];
			

			}
			
		}
		
		
		
		[self loadDocument:[SFileName_Edit stringByDeletingPathExtension] inView:QuestionHeaderBox];
	}
	
	
	else{
		
		
		UIBarButtonItem *NextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style: UIBarButtonItemStyleBordered target:self action:@selector(Next:)];
		
		self.navigationItem.rightBarButtonItem = NextButton;
		
		[self loadDocument:[SFileName stringByDeletingPathExtension] inView:QuestionHeaderBox];
	}
	
	[self.view addSubview:QuestionHeaderBox];
	
	[self.view addSubview:FileListTable];
}


-(void)viewWillAppear:(BOOL)animated{
	
	[self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:1];
}

-(IBAction)NextQuestion:(id)sender{
	
	if (!ShowAnswer) {
	
	
	// Now we need to check the answers agaist what the user have entered. 
	// The answers can be in any order. This will check each Answer if any is wrong then it is wrong.
	
	// Complicated but works.	
	EvaluatorAppDelegate *appDelegate = (EvaluatorAppDelegate *)[UIApplication sharedApplication].delegate;
	NSMutableArray *TempArray =  [[NSMutableArray alloc] initWithArray:[[QItem_View Answers1] allObjects]];
	
	
	int AnswerValues = [AnswerObjects count];
	for (int i = 0; i< AnswerValues; i++) {
		
		NSString *TempVal =[[NSString alloc] initWithString:[[AnswerObjects objectAtIndex:i] valueForKey:@"AnswerText"]];
        // this is important to remove all leading and trailing spaces
        NSString *Val = [TempVal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		Answers *Ans = [AnswerObjects objectAtIndex:i];
		
		for (int P = 0; P < AnswerValues; P++) {
			
			UITextField *TextField = [[AnswerControls objectAtIndex:P] valueForKey:kViewKey];
			
			
			if ([[TextField.text lowercaseString]  isEqualToString:[Val lowercaseString]]) {
				
				[TempArray removeObject:Ans];
				
				
			}
			

		}
			
		
		
		
	}
	int AnswerObjectCount = [TempArray count];
	
	
	if (AnswerObjectCount > 0) {
		// Users Answer is wrong
		// So Do nothing
		
		//Play Saddy Sound
		BOOL PlaySound = [[NSUserDefaults standardUserDefaults] boolForKey:@"PlaySound"];
		
		if (PlaySound == YES) {
			
		[appDelegate PlaySound:@"Cough"];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			
		}
		
		
		
		// if user want answer to be shown then show answer
		
		BOOL ShowMyAnswer = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowMyAnswers"];
		
		if (ShowMyAnswer == YES){
			
			
			ShowAnswer = TRUE;
            [self AdjustScreenToSee: 0]; // To fix the screen 
			[FileListTable reloadData];
            
            if (Specialflag) {
                
                
                NSIndexSet *DeletedSection = [NSIndexSet indexSetWithIndex:0];            
                [FileListTable beginUpdates];
                
                [FileListTable deleteSections:DeletedSection withRowAnimation:UITableViewRowAnimationFade];
                
                [FileListTable endUpdates];
            }
            
            Specialflag = TRUE;

            //[self AdjustScreenToSee: 0];
            
            [self AdjustScreenToSee: 1];

        }
		else {
			
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
	else {
		
		
		
		
		//Play Clappy Sound 
		BOOL PlaySound = [[NSUserDefaults standardUserDefaults] boolForKey:@"PlaySound"];
		if (PlaySound == YES) {
			
			[appDelegate PlaySound:@"Clapping"];
		}
		
		// Users Answer is correct so add the marks on the question to appdelegate.ClientScores
		
		
		NSInteger Counter = [[appDelegate ClientScores]intValue];
		NSNumber *Marks =QItem_View.AllocatedMark;
		
		Counter += [Marks intValue];
		
		appDelegate.ClientScores = [NSNumber numberWithInt:Counter];
		[self.navigationController popViewControllerAnimated:YES];
	}
		
		
	}
	else {
		[self.navigationController popViewControllerAnimated:YES];
	}
	
	
	
}
-(IBAction)Edit:(id)sender{
	
	FillTheBlanks1 *F_view1 = [[FillTheBlanks1 alloc] initWithNibName:nil bundle:nil];
	
	F_view1.QItem_ForEdit = QItem_Edit;
	
	
	[self.navigationController pushViewController:F_view1 animated:YES];
	
	
	
}

-(IBAction)ContinueToNextQuestion:(id)sender{
	
	[self.navigationController popViewControllerAnimated:YES];
	
}


-(IBAction)Next:(id)sender{
	
	FillTheBlanks1 *F_view1 = [[FillTheBlanks1 alloc] initWithNibName:nil bundle:nil];
	
	//F_view1.QItem_ForEdit = QItem_Edit;
	F_view1.QuestionTemplate = self.QuestionTemplate;
	F_view1.SelectedTopic = self.SelectedTopic;
	F_view1.SFileNameValue = self.SFileName;
	
	[self.navigationController pushViewController:F_view1 animated:YES];
	
	
	
}


-(IBAction)Cancel:(id)sender{
	
	//[self dismissModalViewControllerAnimated:YES];
}


-(IBAction)ReportProblem:(id)sender{
	
	if ([MFMailComposeViewController canSendMail]) {
		
		NSArray *SendTo = [NSArray arrayWithObjects:@"Support@LearnersCloud.com",nil];
		
		MFMailComposeViewController *SendMailcontroller = [[MFMailComposeViewController alloc]init];
		SendMailcontroller.mailComposeDelegate = self;
		[SendMailcontroller setToRecipients:SendTo];
		[SendMailcontroller setSubject:[NSString stringWithFormat:@"Ref %@ problem physics question detected on IPhone/IPod",[[NSString stringWithFormat:@"%@",QItem_View.Question] stringByDeletingPathExtension]]];
		
		
		[SendMailcontroller setMessageBody:[NSString stringWithFormat:@"Question Number %@ -- \n Add your message below ", [[NSString stringWithFormat:@"%@",QItem_View.Question] stringByDeletingPathExtension]] isHTML:NO];
		[self presentModalViewController:SendMailcontroller animated:YES];
		
	}
	
	else {
		UIAlertView *Alert = [[UIAlertView alloc] initWithTitle: @"Cannot send mail" 
														message: @"Device is unable to send email in its current state. Configure email" delegate: self 
											  cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		
		
		
		[Alert show];
		
	}
	
	
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
	
	
	[self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];
	
	
	
	
}


-(void)loadDocument:(NSString*)documentName inView:(UIWebView*)webView{
	
    NSString *path = [[NSBundle mainBundle] pathForResource:documentName ofType:@"pdf"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
	
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	
	if (interfaceOrientation == UIInterfaceOrientationPortrait ) {
		
		QuestionHeaderBox.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 300);
		self.FileListTable.frame = CGRectMake(0, 160, SCREEN_WIDTH, SCREEN_HEIGHT - 170);
		Continue.frame = CGRectMake(165, 0, 138, 38);
		
	}
	
	else {
		
		QuestionHeaderBox.frame = CGRectMake(80, 0, SCREEN_HEIGHT - 122, 160);
		self.FileListTable.frame = CGRectMake(0, 160, SCREEN_HEIGHT + 30, SCREEN_HEIGHT - 160);
		Continue.frame = CGRectMake(165, 0, 138, 38);
	}
	
	
}




#pragma mark -
#pragma mark Table view data source



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
	if (QItem_View && ShowAnswer == YES && Specialflag == FALSE) {
		
		return 2;
	}
    else if (QItem_View && ShowAnswer == YES && Specialflag == YES && FromClientAnswer == YES) {
        
        return 1;
    }

	
	else{
		
		return 1;
		
	}


}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	NSString *title;
	
	if (QItem_View && !ShowAnswer ) {
		
		title = @"";
	}
    else if (QItem_View && ShowAnswer && section == 1){
		
		title = @"The correct answer is :";
	}
    
	else if (QItem_Edit){
		
		title = @"Available Files";
	}
    else
    {
        title = @"";
        
    }
	
	return title;  
	

	
	
	
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if(QItem_View && ShowAnswer && section == 1){
        
        UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
        
        // create the button object
        UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.opaque = NO;
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:10];
        headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
        
        headerLabel.text = @"The correct answer is :";
        [customView addSubview:headerLabel];
        
        
        return customView;
    }
    return nil;
}






- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	NSInteger count = 0;
	
	if (QItem_View){
		
		count = [AnswerObjects count] + 1 ; // Add one more roll for controls;
		
	}
	else if (QItem_Edit){
		
		count = [fileList count];
	}
	
	return count; 
	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    WebViewInCell *cell = (WebViewInCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[WebViewInCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
	if (QItem_Edit != nil) {
		// We are in edit mode here so don't show any row
		if (indexPath.row == 0) {
			cell.textLabel.text =@"You can't select file in edit mode";
		}
		return cell;
		
	}
	 else if (QItem_View !=nil && indexPath.row < [AnswerObjects count] ) {
		 
         UITextField *TextField = [[self.AnswerControls objectAtIndex:indexPath.row] valueForKey:kViewKey]; 
         TextField.adjustsFontSizeToFitWidth = YES;
         TextField.borderStyle = UITextBorderStyleRoundedRect;
         TextField.textColor = [UIColor blackColor];
         //TextField.backgroundColor = [UIColor redColor];
         TextField.placeholder = @"<enter answer>";
         TextField.autocorrectionType = UITextAutocorrectionTypeNo;
         
         TextField.textAlignment = UITextAlignmentLeft;
         TextField.tag = indexPath.row;
         //TextField.clearButtonMode = UITextFieldViewModeAlways;
         TextField.delegate = self;
         [cell.contentView addSubview:TextField];
         tableView.allowsSelection = NO;
         
			if ((ShowAnswer == YES && Specialflag == YES && indexPath.section == 1) || (ShowAnswer == YES && Specialflag == YES  && FromClientAnswer == YES)) {
				
				//remove the textField
                [TextField removeFromSuperview];
                
                
                NSMutableString *AnswerText = [NSMutableString stringWithFormat:@"%@",[[AnswerObjects objectAtIndex:indexPath.row] valueForKey:@"AnswerText"]];
                NSMutableString *Reason = [NSMutableString stringWithFormat:@"%@",[[AnswerObjects objectAtIndex:indexPath.row] valueForKey:@"Reason"]];
                NSMutableString *FormatedString =[[NSMutableString alloc]initWithString:@"<p><font size =\"2\" face =\"times new roman \"> "];
                
                [FormatedString appendString:AnswerText];
                [FormatedString appendFormat:@"<br/>"];
                if([Reason isEqualToString:@"(null)"] || !Reason) {
                    
                }
                else 
                { 
                    
                    [FormatedString appendString:Reason]; 
                    
                }
                
                [FormatedString appendString:@"</font></p>"];
                [self configureCell:cell HTMLStr:FormatedString]; // I don't know why this is going to the next cell, to do later
                
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                
				//TextField.text = Val;
				//TextField.enabled = FALSE;
				//[Val release];
				

				

			}
		 
		return cell;
	}
	
	
	 else if(QItem_View !=nil && indexPath.row == [AnswerObjects count] ){
		 
         NSString *ContinueImageLocation = [[NSBundle mainBundle] pathForResource:@"btn_continue" ofType:@"png"];
         UIImage *ContinueImage = [[UIImage alloc] initWithContentsOfFile:ContinueImageLocation];
		 
         Continue = [UIButton buttonWithType:UIButtonTypeCustom];
         [Continue setImage:ContinueImage forState:UIControlStateNormal];

		 
		 [Continue addTarget:self action:@selector(NextQuestion:) forControlEvents:UIControlEventTouchUpInside];
		 [cell addSubview:Continue];
		 
		 if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			 
			Continue.frame = CGRectMake(165, 0, 138, 38);
		 }
		 else {
			 
			Continue.frame = CGRectMake(165, 0, 138, 38);
		 }
		 if(ShowAnswer == YES && RemoveContinueButton == YES)
         {
             
             Continue.hidden = YES;
         }
         

		 
		 
		 return cell;
	 }
	
	
	 else if(QItem_Edit) 
	 {
		 cell.textLabel.text = [NSString stringWithFormat:@"%@",[fileList objectAtIndex:indexPath.row]];
		 return cell;
		 
	 }
	
	return cell;
}

- (void)configureCell:(WebViewInCell *)mycell HTMLStr:(NSString *)value; {
    
    mycell.HTMLText =value;
    
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // increase the size of the answer cell, but ignore the the continue button cell 
    if (indexPath.row != [AnswerObjects count] && ShowAnswer == YES && FromClientAnswer == NO) {
        
		return 270.0;
		
	}
    else if (indexPath.row != [AnswerObjects count] && ShowAnswer == YES && FromClientAnswer == YES ){
        
        return 120;
        
    }
	return 45;
}




- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (QItem_Edit == nil ){
		//not in edit mode
		NSString *FullFileName = [NSString stringWithFormat:@"%@",[fileList objectAtIndex:indexPath.row]];
		[self setSFileName:FullFileName];
		
		[self loadDocument:[SFileName stringByDeletingPathExtension] inView:QuestionHeaderBox];
	}
	
	
	
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
	

	
	/// Fix problem of Keyvboard blocking text fields
	
	switch (textField.tag) {
			
		case 0:
		{
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.3];
			CGRect rect = self.view.frame;
			rect.origin.y = -50;
			rect.size.height = 690;
			self.view.frame = rect;
			[UIView commitAnimations];
			break;
		}
		case 1:
		{
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.3];
			CGRect rect = self.view.frame;
			rect.origin.y = -180;
			rect.size.height = 690;
			self.view.frame = rect;
			[UIView commitAnimations];
			break;
		}
		case 2:
		{
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.3];
			CGRect rect = self.view.frame;
			rect.origin.y = -210;
			rect.size.height = 690;
			self.view.frame = rect;
			[UIView commitAnimations];
			break;
		}
		case 3:
		{
			//CGRect Group = [DisplayTable rectForSection:1];
			//Group.size.height = 600;
			
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.3];
			CGRect rect = self.view.frame;
			rect.origin.y = -240;
			rect.size.height = 690;
			self.view.frame = rect;
			[UIView commitAnimations];
			break;
		}
		case 4:
		{
			
			
			
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.3];
			CGRect rect = self.view.frame;
			rect.origin.y = -270;
			rect.size.height = 690;
			self.view.frame = rect;
			[UIView commitAnimations];
			break;
		}
		default:
			break;
	}
	
	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[textField resignFirstResponder];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	CGRect rect = self.view.frame;
	rect.origin.y = 0;
	rect.size.height = 450;
	self.view.frame = rect;
	[UIView commitAnimations];
	
	
	return YES;
}

- (void)AdjustScreenToSee:(int)value{
	
	if(value == 1){
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        CGRect rect = self.FileListTable.frame;
        rect.origin.y = -345;
        rect.size.height = 820;
        self.FileListTable.frame = rect;
        [UIView commitAnimations];
	}
	
	else {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        CGRect rect = self.view.frame;
        rect.origin.y = 0;
        rect.size.height = 450;
        self.view.frame = rect;
        [UIView commitAnimations];
		
	}
    
	
	
}


-(IBAction)StopTest:(id)sender {
    
    EvaluatorAppDelegate *appDelegate = (EvaluatorAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.FinishTestNow = YES;
    [self ContinueToNextQuestion:nil];
}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	QuestionHeaderBox = nil;
}




@end
