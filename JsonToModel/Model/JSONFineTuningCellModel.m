#import "JSONFineTuningCellModel.h"

@implementation JSONFineTuningCellModel
- (NSMutableArray *)dataArr{
	if (!_dataArr) {
		_dataArr=[NSMutableArray array];
	}
	return _dataArr;
}
- (void)setAutoWidthText:(NSString *)autoWidthText{
	_autoWidthText=autoWidthText;
}

@end
