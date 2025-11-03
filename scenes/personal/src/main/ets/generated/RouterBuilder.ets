import { HelpPage } from '../pages/Help';
import { OpenVipPage } from '../pages/OpenVip';
import { OtherLogin } from '../pages/OtherLogin';
import { QuickLoginPage } from '../pages/QuickLoginPage';
import { SaveSettingPage } from '../pages/SaveSetting';
import { SettingPage } from '../pages/Setting';
import { TermsPage } from '../pages/Terms';

@Builder
export function OpenVipBuilder() {
  OpenVipPage();
}

@Builder
export function SettingBuilder() {
  SettingPage();
}

@Builder
export function SaveSettingBuilder() {
  SaveSettingPage();
}

@Builder
export function TermsBuilder() {
  TermsPage();
}

@Builder
export function HelpBuilder() {
  HelpPage();
}

@Builder
export function QuickLoginPageBuilder() {
  QuickLoginPage();
}

@Builder
export function OtherLoginPageBuilder() {
  OtherLogin();
}

