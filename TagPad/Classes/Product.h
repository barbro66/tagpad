
@interface Product : NSObject {
	NSString *type;
	NSString *name;
}

@property (nonatomic, copy) NSString *type, *name;

+ (id)productWithType:(NSString *)type name:(NSString *)name;

@end
