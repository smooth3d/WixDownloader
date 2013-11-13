#import "AppDelegate.h"
//#include <stdlib.h>

@implementation AppDelegate
NSThread *thread;

-(NSString*)downloadFile:(NSString*)url
{
    [self Debug:[NSString stringWithFormat:@"Downloading URL: %@", url]];
    
    NSHTTPURLResponse *urlResponse = nil;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    [request setHTTPMethod:@"GET"];
    [request addValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:25.0) Gecko/20100101 Firefox/25.0" forHTTPHeaderField: @"User-Agent"];
    
    NSData *indexData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
    
    if ([urlResponse statusCode] == 200)
    {
        return [[NSString alloc] initWithData:indexData encoding:NSUTF8StringEncoding];
    }
    else
    {
        return NULL;
    }
}

-(void)startThread
{
    NSString *indexHTML = [self downloadFile:[site stringValue]];
    
    NSArray *jsonHTTP = [indexHTML componentsSeparatedByString: @","];
    NSString* DownloadPath = [NSString stringWithFormat:@"%@/Downloads/%@",NSHomeDirectory(),[[domain stringValue] stringByReplacingOccurrencesOfString:@"http://" withString:@""]];
    NSError * error = nil;
    
    if ([media state] == NSOnState)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/media",DownloadPath] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    for(int i = 0; i < [jsonHTTP count]; i++)
    {
        if ([[jsonHTTP objectAtIndex:i] rangeOfString:@"\"http://"].location != NSNotFound)
        {
            NSArray *http = [[jsonHTTP objectAtIndex:i] componentsSeparatedByString: @"\""];
            for(int h = 0; h < [http count]; h++)
            {
                if([[NSThread currentThread] isCancelled])
                    [NSThread exit];
                
                if ([[http objectAtIndex:h] rangeOfString:@"http://"].location != NSNotFound)
                {
                    //NSLog(@"> %@", [http objectAtIndex:h]);
                    
                    NSString* dirRoot= [[NSString alloc] init];
                    NSArray* domainRoot = [[[http objectAtIndex:h] stringByReplacingOccurrencesOfString:@"http://" withString:@""] componentsSeparatedByString: @"/"];
                    
                    indexHTML = [indexHTML stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"http://%@",[domainRoot objectAtIndex:0]] withString:[domain stringValue]];
                    
                    //NSLog(@"%@", domainRoot);
                    
                    for(int d = 1; d < [domainRoot count] -1; d++)
                    {
                        dirRoot = [dirRoot stringByAppendingString:[NSString stringWithFormat:@"%@/",[domainRoot objectAtIndex:d]]];
                    }

                    dirRoot = [dirRoot stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    dirRoot = [dirRoot stringByReplacingOccurrencesOfString:@"]" withString:@""];
                    dirRoot = [dirRoot stringByReplacingOccurrencesOfString:@"}" withString:@""];
                    
                    [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",DownloadPath,dirRoot] withIntermediateDirectories:YES attributes:nil error:&error];
                    
                    //[self Debug:[NSString stringWithFormat:@"Directory Create: %@/%@", DownloadPath, dirRoot]];
                    
                    NSString* webfile = [self downloadFile:[http objectAtIndex:h]];
                    if(webfile != NULL)
                    {
                     
                    if ([media state] == NSOnState)
                    {
                        NSArray *uri = [webfile componentsSeparatedByString: @","];
                        for(int u = 0; u < [uri count]; u++)
                        {
                            if ([[uri objectAtIndex:u] rangeOfString:@"\"uri\":"].location != NSNotFound)
                            {
                                NSString* img = [[uri objectAtIndex:u] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                                img = [img stringByReplacingOccurrencesOfString:@"uri:" withString:@""];
                                
                                NSData* webBinary = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://static.wixstatic.com/media/%@",img]]];
                                
                                if ([webBinary writeToFile:[NSString stringWithFormat:@"%@/media/%@",DownloadPath,img] atomically:YES])
                                {
                                    [self Debug:[NSString stringWithFormat:@"Downloading Media: %@", img]];
                                }
                            }
                        }
                    }
                    
                    [webfile writeToFile:[NSString stringWithFormat:@"%@/%@/%@",DownloadPath,dirRoot,[domainRoot objectAtIndex:[domainRoot count]-1]] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    }
              
                    break;
                }
            }
        }
    }

    [indexHTML writeToFile:[NSString stringWithFormat:@"%@/index.html",DownloadPath] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    [self Debug:@"Downloading Finished"];
    
    [download setTitle:@"Download"];
    [loading stopAnimation: self];
    [loading setHidden:TRUE];
}

- (IBAction)download_Click:(id)sender;
{
    if([thread isExecuting])
    {
        [thread cancel];
        [self Debug:@"Downloading Stopped"];
        [download setTitle:@"Download"];
        
        [loading stopAnimation: self];
        [loading setHidden:TRUE];
    }
    else
    {
        [log setStringValue:@""];
        [loading setHidden:FALSE];
        [loading startAnimation: self];
        
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(startThread) object:nil];
        [thread start];
        [self Debug:@"Downloading Started"];
        [download setTitle:@"Stop"];
    }
}

- (void)writeDebug:(NSString*)d
{
    [log setStringValue:[[log stringValue] stringByAppendingString:[NSString stringWithFormat:@"%@\n",d]]];
}

- (void)Debug:(NSString*)d
{
    //[self performSelectorInBackground:@selector(writeDebug:) withObject:d];
    [log setStringValue:[[log stringValue] stringByAppendingString:[NSString stringWithFormat:@"%@\n",d]]];
    NSLog(@"%@",d);
}
@end
