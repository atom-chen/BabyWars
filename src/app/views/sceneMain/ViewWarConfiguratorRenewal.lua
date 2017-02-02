
local ViewWarConfiguratorRenewal = class("ViewWarConfiguratorRenewal", cc.Node)

local DisplayNodeFunctions  = require("src.app.utilities.DisplayNodeFunctions")
local LocalizationFunctions = require("src.app.utilities.LocalizationFunctions")

local getLocalizedText = LocalizationFunctions.getLocalizedText

local POPUP_SCROLLVIEW_Z_ORDER    = 3
local POPUP_BACKGROUND_Z_ORDER    = 2
local POPUP_GREY_MASK_Z_ORDER     = 1
local MENU_TITLE_Z_ORDER          = 1
local MENU_LIST_VIEW_Z_ORDER      = 1
local BUTTON_BACK_Z_ORDER         = 1
local BUTTON_CONFIRM_Z_ORDER      = 1
local MENU_BACKGROUND_Z_ORDER     = 0

local MENU_BACKGROUND_WIDTH     = 250
local MENU_BACKGROUND_HEIGHT    = display.height - 60
local MENU_BACKGROUND_POS_X     = 30
local MENU_BACKGROUND_POS_Y     = 30
local MENU_BACKGROUND_CAPINSETS = {x = 4, y = 6, width = 1, height = 1}

local MENU_TITLE_WIDTH      = MENU_BACKGROUND_WIDTH
local MENU_TITLE_HEIGHT     = 60
local MENU_TITLE_POS_X      = MENU_BACKGROUND_POS_X
local MENU_TITLE_POS_Y      = MENU_BACKGROUND_POS_Y + MENU_BACKGROUND_HEIGHT - MENU_TITLE_HEIGHT
local MENU_TITLE_FONT_COLOR = {r = 96,  g = 224, b = 88}
local MENU_TITLE_FONT_SIZE  = 35

local ITEM_WIDTH     = 230
local ITEM_HEIGHT    = 50
local ITEM_CAPINSETS = {x = 1, y = ITEM_HEIGHT, width = 1, height = 1}

local EDIT_BOX_PASSWORD_WIDTH  = 250 -- The same as the width of the indicator of ViewOptionSelector
local EDIT_BOX_PASSWORD_HEIGHT = 50  -- The same as the height of the indicator of ViewOptionSelector

local BUTTON_BACK_WIDTH  = MENU_BACKGROUND_WIDTH
local BUTTON_BACK_HEIGHT = 50
local BUTTON_BACK_POS_X  = MENU_BACKGROUND_POS_X
local BUTTON_BACK_POS_Y  = MENU_BACKGROUND_POS_Y

local BUTTON_CONFIRM_WIDTH     = display.width - MENU_BACKGROUND_WIDTH - 90
local BUTTON_CONFIRM_HEIGHT    = 60
local BUTTON_CONFIRM_POS_X     = MENU_BACKGROUND_POS_X + MENU_BACKGROUND_WIDTH + 30
local BUTTON_CONFIRM_POS_Y     = MENU_BACKGROUND_POS_Y
local BUTTON_CONFIRM_FONT_SIZE = 30

local MENU_LIST_VIEW_WIDTH        = MENU_BACKGROUND_WIDTH
local MENU_LIST_VIEW_HEIGHT       = MENU_TITLE_POS_Y - BUTTON_BACK_POS_Y - BUTTON_BACK_HEIGHT
local MENU_LIST_VIEW_POS_X        = MENU_BACKGROUND_POS_X
local MENU_LIST_VIEW_POS_Y        = BUTTON_BACK_POS_Y + BUTTON_BACK_HEIGHT
local MENU_LIST_VIEW_ITEMS_MARGIN = 10

local EDIT_BOX_PASSWORD_CAPINSETS       = {x = 1, y = EDIT_BOX_PASSWORD_HEIGHT - 7, width = 1, height = 1}
local EDIT_BOX_PASSWORD_TITLE_FONT_SIZE = 16
local EDIT_BOX_PASSWORD_FONT_SIZE       = 25

local FONT_NAME          = "res/fonts/msyhbd.ttc"
local FONT_COLOR         = {r = 255, g = 255, b = 255}
local FONT_OUTLINE_COLOR = {r = 0,   g = 0,   b = 0}
local FONT_OUTLINE_WIDTH = 2
local ITEM_FONT_SIZE     = 25
local POPUP_FONT_SIZE    = 18

local BUTTON_BACKGROUND_NAME      = "c03_t01_s01_f01.png"
local BUTTON_BACKGROUND_CAPINSETS = {x = 4, y = 6, width = 1, height = 1}

local POPUP_BACKGROUND_WIDTH  = display.width  * 0.7
local POPUP_BACKGROUND_HEIGHT = display.height * 0.8
local POPUP_BACKGROUND_POS_X  = (display.width  - POPUP_BACKGROUND_WIDTH)  / 2
local POPUP_BACKGROUND_POS_Y  = (display.height - POPUP_BACKGROUND_HEIGHT) / 2

local POPUP_SCROLLVIEW_WIDTH  = POPUP_BACKGROUND_WIDTH  - 7
local POPUP_SCROLLVIEW_HEIGHT = POPUP_BACKGROUND_HEIGHT - 11
local POPUP_SCROLLVIEW_POS_X  = POPUP_BACKGROUND_POS_X + 5
local POPUP_SCROLLVIEW_POS_Y  = POPUP_BACKGROUND_POS_Y + 5

--------------------------------------------------------------------------------
-- The util functions.
--------------------------------------------------------------------------------
local function createViewItem(item)
    local label = cc.Label:createWithTTF(item.name, FONT_NAME, ITEM_FONT_SIZE)
    label:ignoreAnchorPointForPosition(true)

        :setDimensions(ITEM_WIDTH, ITEM_HEIGHT)
        :setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        :setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)

        :setTextColor(FONT_COLOR)
        :enableOutline(FONT_OUTLINE_COLOR, FONT_OUTLINE_WIDTH)

    local view = ccui.Button:create()
    view:loadTextureNormal("c03_t06_s01_f01.png", ccui.TextureResType.plistType)

        :setScale9Enabled(true)
        :setCapInsets(ITEM_CAPINSETS)
        :setContentSize(ITEM_WIDTH, ITEM_HEIGHT)

        :setZoomScale(-0.05)

        :addTouchEventListener(function(sender, eventType)
            if (eventType == ccui.TouchEventType.ended) then
                item.callback()
            end
        end)
    view:getRendererNormal():addChild(label)

    return view
end

--------------------------------------------------------------------------------
-- The composition elements.
--------------------------------------------------------------------------------
local function initMenuBackground(self)
    local background = cc.Scale9Sprite:createWithSpriteFrameName("c03_t01_s01_f01.png", MENU_BACKGROUND_CAPINSETS)
    background:ignoreAnchorPointForPosition(true)
        :setPosition(MENU_BACKGROUND_POS_X, MENU_BACKGROUND_POS_Y)
        :setContentSize(MENU_BACKGROUND_WIDTH, MENU_BACKGROUND_HEIGHT)
        :setOpacity(180)

    self.m_MenuBackground = background
    self:addChild(background, MENU_BACKGROUND_Z_ORDER)
end

local function initMenuListView(self)
    local listView = ccui.ListView:create()
    listView:setPosition(MENU_LIST_VIEW_POS_X, MENU_LIST_VIEW_POS_Y)
        :setContentSize(MENU_LIST_VIEW_WIDTH, MENU_LIST_VIEW_HEIGHT)
        :setItemsMargin(MENU_LIST_VIEW_ITEMS_MARGIN)
        :setGravity(ccui.ListViewGravity.centerHorizontal)

    self.m_MenuListView = listView
    self:addChild(listView, MENU_LIST_VIEW_Z_ORDER)
end

local function initMenuTitle(self)
    local title = cc.Label:createWithTTF(getLocalizedText(1, "NewGame"), FONT_NAME, MENU_TITLE_FONT_SIZE)
    title:ignoreAnchorPointForPosition(true)
        :setPosition(MENU_TITLE_POS_X, MENU_TITLE_POS_Y)

        :setDimensions(MENU_TITLE_WIDTH, MENU_TITLE_HEIGHT)
        :setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        :setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)

        :setTextColor(MENU_TITLE_FONT_COLOR)
        :enableOutline(FONT_OUTLINE_COLOR, FONT_OUTLINE_WIDTH)

    self.m_MenuTitle = title
    self:addChild(title, MENU_TITLE_Z_ORDER)
end

local function initEditBoxPassword(self)
    local titleLabel = cc.Label:createWithTTF(getLocalizedText(34, "Password"), FONT_NAME, EDIT_BOX_PASSWORD_TITLE_FONT_SIZE)
    titleLabel:ignoreAnchorPointForPosition(true)
        :enableOutline(FONT_OUTLINE_COLOR, FONT_OUTLINE_WIDTH)

        :setDimensions(EDIT_BOX_PASSWORD_WIDTH, EDIT_BOX_PASSWORD_HEIGHT + 25)
        :setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        :setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)

    local background = cc.Scale9Sprite:createWithSpriteFrameName(BUTTON_BACKGROUND_NAME, BUTTON_BACKGROUND_CAPINSETS)
    background:setOpacity(180)

    local editBox = ccui.EditBox:create(cc.size(EDIT_BOX_PASSWORD_WIDTH, EDIT_BOX_PASSWORD_HEIGHT), background, background, background)
    editBox:ignoreAnchorPointForPosition(true)
        :setPosition(EDIT_BOX_PASSWORD_POS_X, EDIT_BOX_PASSWORD_POS_Y)
        :setFontSize(EDIT_BOX_PASSWORD_FONT_SIZE)
        :setFontColor({r = 0, g = 0, b = 0})

        :setPlaceholderFontSize(EDIT_BOX_PASSWORD_FONT_SIZE)
        :setPlaceholderFontColor({r = 0, g = 0, b = 0})
        :setPlaceHolder(getLocalizedText(47))

        :setMaxLength(4)
        :setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        :setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)

        :addChild(titleLabel)

    self:addChild(editBox)
    self.m_EditBoxPassword = editBox
end

local function initButtonBack(self)
    local button = ccui.Button:create()
    button:ignoreAnchorPointForPosition(true)
        :setPosition(BUTTON_BACK_POS_X, BUTTON_BACK_POS_Y)

        :setScale9Enabled(true)
        :setContentSize(BUTTON_BACK_WIDTH, BUTTON_BACK_HEIGHT)

        :setZoomScale(-0.05)

        :setTitleFontName(FONT_NAME)
        :setTitleFontSize(ITEM_FONT_SIZE)
        :setTitleColor({r = 240, g = 80, b = 56})
        :setTitleText(getLocalizedText(1, "Back"))

        :addTouchEventListener(function(sender, eventType)
            if ((eventType == ccui.TouchEventType.ended) and (self.m_Model)) then
                self.m_Model:onButtonBackTouched()
            end
        end)

    button:getTitleRenderer():enableOutline(FONT_OUTLINE_COLOR, FONT_OUTLINE_WIDTH)

    self.m_ButtonBack = button
    self:addChild(button, BUTTON_BACK_Z_ORDER)
end

local function initButtonConfirm(self)
    local button = ccui.Button:create()
    button:loadTextureNormal("c03_t01_s01_f01.png", ccui.TextureResType.plistType)

        :setScale9Enabled(true)
        :setCapInsets(MENU_BACKGROUND_CAPINSETS)
        :setContentSize(BUTTON_CONFIRM_WIDTH, BUTTON_CONFIRM_HEIGHT)

        :setZoomScale(-0.05)
        :setOpacity(180)

        :ignoreAnchorPointForPosition(true)
        :setPosition(BUTTON_CONFIRM_POS_X, BUTTON_CONFIRM_POS_Y)

        :setTitleFontName(FONT_NAME)
        :setTitleFontSize(BUTTON_CONFIRM_FONT_SIZE)
        :setTitleColor(FONT_COLOR)
        :setTitleText(getLocalizedText(1, "Confirm"))

        :addTouchEventListener(function(sender, eventType)
            if ((eventType == ccui.TouchEventType.ended) and (self.m_Model)) then
                self.m_Model:onButtonNextTouched()
            end
        end)

    button:getTitleRenderer():enableOutline(FONT_OUTLINE_COLOR, FONT_OUTLINE_WIDTH)

    self.m_ButtonConfirm = button
    self:addChild(button, BUTTON_CONFIRM_Z_ORDER)
end

local function initPopUpPanel(self)
    local mask = cc.LayerColor:create({r = 0, g = 0, b = 0, a = 140})
    mask:setContentSize(display.width, display.height)
        :ignoreAnchorPointForPosition(true)

    local background = cc.Scale9Sprite:createWithSpriteFrameName(BUTTON_BACKGROUND_NAME, BUTTON_BACKGROUND_CAPINSETS)
    background:ignoreAnchorPointForPosition(true)
        :setPosition(POPUP_BACKGROUND_POS_X, POPUP_BACKGROUND_POS_Y)
        :setContentSize(POPUP_BACKGROUND_WIDTH, POPUP_BACKGROUND_HEIGHT)

    local scrollView = ccui.ScrollView:create()
    scrollView:setContentSize(POPUP_SCROLLVIEW_WIDTH, POPUP_SCROLLVIEW_HEIGHT)
        :ignoreAnchorPointForPosition(true)
        :setPosition(POPUP_SCROLLVIEW_POS_X, POPUP_SCROLLVIEW_POS_Y)

    local label = cc.Label:createWithTTF("", FONT_NAME, POPUP_FONT_SIZE)
    label:ignoreAnchorPointForPosition(true)
        :setDimensions(POPUP_SCROLLVIEW_WIDTH, POPUP_SCROLLVIEW_HEIGHT)
        :enableOutline(FONT_OUTLINE_COLOR, FONT_OUTLINE_WIDTH)
    scrollView:addChild(label)

    self.m_PopUpGreyMask   = mask
    self.m_PopUpBackground = background
    self.m_PopUpScrollView = scrollView
    self.m_PopUpLabel      = label
    self:addChild(mask,       POPUP_GREY_MASK_Z_ORDER)
        :addChild(background, POPUP_BACKGROUND_Z_ORDER)
        :addChild(scrollView, POPUP_SCROLLVIEW_Z_ORDER)
end

local function initPopUpTouchListener(self)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    local isTouchWithinBackground = false

    listener:registerScriptHandler(function(touch, event)
        isTouchWithinBackground = DisplayNodeFunctions.isTouchWithinNode(touch, self.m_PopUpBackground)
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    listener:registerScriptHandler(function(touch, event)
        if (not isTouchWithinBackground) then
            self:setPopUpPanelEnabled(false)
        end
    end, cc.Handler.EVENT_TOUCH_ENDED)

    self.m_PopUpTouchListener = listener
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.m_PopUpBackground)
end

--------------------------------------------------------------------------------
-- The constructor and initializers.
--------------------------------------------------------------------------------
function ViewWarConfiguratorRenewal:ctor()
    -- initEditBoxPassword(   self)

    initMenuBackground(    self)
    initMenuListView(      self)
    initMenuTitle(         self)
    initButtonBack(        self)
    initButtonConfirm(     self)
    initPopUpPanel(        self)
    initPopUpTouchListener(self)
    self:setPopUpPanelEnabled(false)

    return self
end

--------------------------------------------------------------------------------
-- The public functions.
--------------------------------------------------------------------------------
function ViewWarConfiguratorRenewal:removeAllItems()
    self.m_MenuListView:removeAllItems()

    return self
end

function ViewWarConfiguratorRenewal:setItems(items)
    local listView = self.m_MenuListView
    listView:removeAllItems()

    for _, item in ipairs(items) do
        listView:pushBackCustomItem(createViewItem(item))
    end

    return self
end

function ViewWarConfiguratorRenewal:getEditBoxPassword()
    return self.m_EditBoxPassword
end

function ViewWarConfiguratorRenewal:disableButtonConfirmForSecs(secs)
    self.m_ButtonConfirm:setEnabled(false)
        :stopAllActions()
        :runAction(cc.Sequence:create(
            cc.DelayTime:create(secs),
            cc.CallFunc:create(function()
                self.m_ButtonConfirm:setEnabled(true)
            end)
        ))

    return self
end

function ViewWarConfiguratorRenewal:isPopUpPanelEnabled(enabled)
    return self.m_PopUpGreyMask:isVisible()
end

function ViewWarConfiguratorRenewal:setPopUpPanelEnabled(enabled)
    self.m_PopUpGreyMask     :setVisible(enabled)
    self.m_PopUpBackground   :setVisible(enabled)
    self.m_PopUpScrollView   :setVisible(enabled)
    self.m_PopUpTouchListener:setEnabled(enabled)

    return self
end

function ViewWarConfiguratorRenewal:setPopUpPanelText(text)
    local label = self.m_PopUpLabel
    label:setString(text)

    local height = math.max(label:getLineHeight() * label:getStringNumLines(), POPUP_SCROLLVIEW_HEIGHT)
    label:setDimensions(POPUP_SCROLLVIEW_WIDTH, height)
    self.m_PopUpScrollView:setInnerContainerSize({width = POPUP_SCROLLVIEW_WIDTH, height = height})

    return self
end

return ViewWarConfiguratorRenewal
