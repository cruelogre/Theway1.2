local registry = {
	stateName = "UILoginRootState";
	resData = {};
	controller = "login.fsm.controller.UILoginRootState";
	entry = true;
	
	push = {
		
	};
	pop = {
		{eventName="back"}
	}
}
registry.resData.Texture = {
	--"login/login_bg.jpg"
}
return registry