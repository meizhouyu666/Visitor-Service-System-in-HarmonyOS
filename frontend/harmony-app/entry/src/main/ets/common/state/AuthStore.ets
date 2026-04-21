import { apiClient } from '../network/ApiClient'
import {
  CurrentUser,
  LoginRequest,
  LoginResponse,
  RegisterRequest,
  RegisterResponse,
  RequestResetCodeRequest,
  RequestResetCodeResponse,
  ResetPasswordRequest,
  UserRole
} from '../model/ApiModels'

@Observed
export class AuthStore {
  token: string = ''
  currentUser: CurrentUser | null = null
  loading: boolean = false
  errorMessage: string = ''
  infoMessage: string = ''

  async login(request: LoginRequest): Promise<boolean> {
    this.loading = true
    this.errorMessage = ''
    this.infoMessage = ''
    try {
      const result: LoginResponse = await apiClient.post<LoginRequest, LoginResponse>('/api/auth/login', request)
      this.token = result.token
      apiClient.setToken(result.token)
      this.currentUser = await apiClient.get<CurrentUser>('/api/auth/me')
      this.infoMessage = '登录成功'
      return true
    } catch (error) {
      if (error instanceof Error && error.message.trim().length > 0) {
        this.errorMessage = `登录失败：${error.message}`
      } else {
        this.errorMessage = '登录失败：账号或密码错误'
      }
      return false
    } finally {
      this.loading = false
    }
  }

  async register(request: RegisterRequest): Promise<boolean> {
    this.loading = true
    this.errorMessage = ''
    this.infoMessage = ''
    try {
      const result: RegisterResponse = await apiClient.post<RegisterRequest, RegisterResponse>('/api/auth/register', request)
      this.infoMessage = `注册成功：${result.username}`
      return true
    } catch (_error) {
      this.errorMessage = '注册失败：用户名可能已存在'
      return false
    } finally {
      this.loading = false
    }
  }

  async requestResetCode(request: RequestResetCodeRequest): Promise<RequestResetCodeResponse | null> {
    this.loading = true
    this.errorMessage = ''
    this.infoMessage = ''
    try {
      const result: RequestResetCodeResponse = await apiClient.post<RequestResetCodeRequest, RequestResetCodeResponse>(
        '/api/auth/forgot-password/request-code',
        request
      )
      this.infoMessage = `验证码：${result.debugCode}（有效至 ${result.expiresAt}）`
      return result
    } catch (_error) {
      this.errorMessage = '获取验证码失败：请确认账号是否存在'
      return null
    } finally {
      this.loading = false
    }
  }

  async resetPassword(request: ResetPasswordRequest): Promise<boolean> {
    this.loading = true
    this.errorMessage = ''
    this.infoMessage = ''
    try {
      await apiClient.post<ResetPasswordRequest, Record<string, string>>('/api/auth/forgot-password/reset', request)
      this.infoMessage = '密码重置成功，请使用新密码登录'
      return true
    } catch (_error) {
      this.errorMessage = '密码重置失败：验证码错误或已过期'
      return false
    } finally {
      this.loading = false
    }
  }

  logout(): void {
    this.token = ''
    this.currentUser = null
    apiClient.setToken('')
    this.errorMessage = ''
    this.infoMessage = ''
  }

  getRole(): UserRole {
    const role: string = this.currentUser?.role ?? 'VISITOR'
    switch (role) {
      case 'ADMIN':
      case 'COMPLAINT_HANDLER':
      case 'HOTEL_ADMIN':
      case 'SYSTEM_ADMIN':
      case 'VISITOR':
        return role
      case 'EMERGENCY_WRITER':
      case 'APPROVER':
        return 'ADMIN'
      case 'HOTEL_MANAGER':
      case 'HOTELADMIN':
        return 'HOTEL_ADMIN'
      default:
        return 'VISITOR'
    }
  }

  hasPermission(permission: string): boolean {
    const permissions: string[] = this.currentUser?.permissions ?? []
    return permissions.includes(permission)
  }

  hasRole(role: UserRole): boolean {
    return this.getRole() === role
  }

  hasAnyRole(roles: UserRole[]): boolean {
    return roles.includes(this.getRole())
  }

  getRoleLabel(): string {
    const role: UserRole = this.getRole()
    switch (role) {
      case 'VISITOR':
        return '游客'
      case 'COMPLAINT_HANDLER':
        return '投诉处理员'
      case 'HOTEL_ADMIN':
        return '酒店管理员'
      case 'SYSTEM_ADMIN':
        return '系统管理员'
      case 'ADMIN':
        return '平台管理员'
      default:
        return '游客'
    }
  }
}
