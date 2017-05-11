local registry = {
	stateName = "UILoginButtonViewState";
	resData = {};
	controller = "login.fsm.controller.UILoginButtonViewState";
	view = "login.mediator.view.LoginButtonView";
	
	entry = false;
	enter = {
		{eventName="test";stateName="UITestViewState"},
		{eventName="test1";stateName="UITestView2State"}
		};
	push = {};
	pop = {
		{eventName="back"}
	}
}
registry.resData.Texture = {
"login/login_btn_quickStart.png",
"login/login_btn_switchAccount.png"
}

return registry