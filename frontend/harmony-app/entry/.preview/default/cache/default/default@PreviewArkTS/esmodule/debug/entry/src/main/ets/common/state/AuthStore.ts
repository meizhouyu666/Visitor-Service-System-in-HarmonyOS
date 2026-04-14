import { apiClient } from "@normalized:N&&&entry/src/main/ets/common/network/ApiClient&";
import type { CurrentUser, LoginRequest, LoginResponse } from '../model/ApiModels';
@Observed
export class AuthStore {
    token: string = '';
    currentUser: CurrentUser | null = null;
    loading: boolean = false;
    errorMessage: string = '';
    async login(request: LoginRequest): Promise<void> {
        this.loading = true;
        this.errorMessage = '';
        try {
            const result: LoginResponse = await apiClient.post<LoginRequest, LoginResponse>('/api/auth/login', request);
            this.token = result.token;
            apiClient.setToken(result.token);
            this.currentUser = await apiClient.get<CurrentUser>('/api/auth/me');
        }
        catch (error) {
            const errMsg = (error as Error)?.message || '';
            if (errMsg.includes('user not found') || errMsg.includes('username not found')) {
                this.errorMessage = '登录失败：账号不存在';
            }
            else if (errMsg.includes('invalid password') || errMsg.includes('password error')) {
                this.errorMessage = '登录失败：密码不正确';
            }
            else {
                this.errorMessage = '登录失败：账号或密码错误';
            }
        }
        finally {
            this.loading = false;
        }
    }
    logout(): void {
        this.token = '';
        this.currentUser = null;
        apiClient.setToken('');
    }
}
