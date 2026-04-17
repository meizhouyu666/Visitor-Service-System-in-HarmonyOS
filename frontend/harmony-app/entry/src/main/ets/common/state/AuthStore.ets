import { apiClient } from '../network/ApiClient'
import { CurrentUser, LoginRequest, LoginResponse, UserRole } from '../model/ApiModels'

@Observed
export class AuthStore {
  token: string = ''
  currentUser: CurrentUser | null = null
  loading: boolean = false
  errorMessage: string = ''

  async login(request: LoginRequest): Promise<boolean> {
    this.loading = true
    this.errorMessage = ''
    try {
      const result: LoginResponse = await apiClient.post<LoginRequest, LoginResponse>('/api/auth/login', request)
      this.token = result.token
      apiClient.setToken(result.token)
      this.currentUser = await apiClient.get<CurrentUser>('/api/auth/me')
      return true
    } catch (_error) {
      this.errorMessage = '登录失败：账号或密码错误'
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
  }

  getRole(): UserRole {
    const role: string = this.currentUser?.role ?? 'VISITOR'
    switch (role) {
      case 'ADMIN':
      case 'COMPLAINT_HANDLER':
      case 'EMERGENCY_WRITER':
      case 'APPROVER':
      case 'HOTEL_MANAGER':
      case 'SYSTEM_ADMIN':
      case 'VISITOR':
        return role
      default:
        return 'VISITOR'
    }
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
      case 'EMERGENCY_WRITER':
        return '应急发布员'
      case 'APPROVER':
        return '审批员'
      case 'HOTEL_MANAGER':
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