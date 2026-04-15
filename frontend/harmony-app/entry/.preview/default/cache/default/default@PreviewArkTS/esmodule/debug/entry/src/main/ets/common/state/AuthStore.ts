import { apiClient } from "@normalized:N&&&entry/src/main/ets/common/network/ApiClient&";
import type { CurrentUser, LoginRequest, LoginResponse } from '../model/ApiModels';
@Observed
export class AuthStore {
    token: string = '';
    currentUser: CurrentUser | null = null;
    loading: boolean = false;
    errorMessage: string = '';
    async login(request: LoginRequest): Promise<boolean> {
        this.loading = true;
        this.errorMessage = '';
        try {
            const result: LoginResponse = await apiClient.post<LoginRequest, LoginResponse>('/api/auth/login', request);
            this.token = result.token;
            apiClient.setToken(result.token);
            // 获取当前用户信息
            this.currentUser = await apiClient.get<CurrentUser>('/api/auth/me');
            return true;
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
            return false;
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
    // 获取用户角色显示名称
    getUserRole(): string {
        if (!this.currentUser)
            return '访客';
        if (this.currentUser.role === 'ADMIN') {
            return '管理员';
        }
        return '普通用户';
    }
    // 检查是否有指定角色
    hasRole(role: string): boolean {
        if (!this.currentUser)
            return false;
        return this.currentUser.role === role;
    }
}
