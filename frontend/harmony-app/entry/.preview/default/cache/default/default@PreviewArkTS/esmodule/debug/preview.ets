struct preview{build(){Text(`当前用户：${this.authStore.currentUser?.displayName ?? 'Admin'}`)
          .fontSize(16)
          .fontColor('#4B5563')}}