// 页面 : 登录页面 
LJRouterUsePage(login);
// action : 判断登录状态,弹出登录页面 
LJRouterUseAction(loginIfNeed, void, (UIViewController*)curVC, (void(^)(BOOL))finishBlock);
// action : 是否登录状态 
LJRouterUseAction(isLogin, BOOL);
// action : 退出登录 
LJRouterUseAction(logout, void);
