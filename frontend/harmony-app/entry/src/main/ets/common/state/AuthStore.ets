import { apiClient } from '../network/ApiClient'
import { CurrentUser, LoginRequest, LoginResponse } from '../model/ApiModels'

@Observed
export class AuthStore {
  token: string = ''
  currentUser: CurrentUser | null = null
  loading: boolean = false
  errorMessage: string = ''

  async login(request: LoginRequest): Promise<void> {
    this.loading = true
    this.errorMessage = ''
    try {
      const result: LoginResponse = await apiClient.post<LoginRequest, LoginResponse>('/api/auth/login', request)
      this.token = result.token
      apiClient.setToken(result.token)
      this.currentUser = await apiClient.get<CurrentUser>('/api/auth/me')
    } catch (error) {
      this.errorMessage = `Login failed: ${JSON.stringify(error)}`
    } finally {
      this.loading = false
    }
  }

  logout(): void {
    this.token = ''
    this.currentUser = null
    apiClient.setToken('')
  }
}
