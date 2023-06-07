defmodule KnitMakerWeb.Router do
  use KnitMakerWeb, :router

  import KnitMakerWeb.UserAuth

  @ensure_authenticated {KnitMakerWeb.UserAuth, :ensure_authenticated}

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {KnitMakerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KnitMakerWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  pipeline :participant_session do
    plug KnitMakerWeb.Plug.ParticipantSession
  end

  ## Authentication routes

  scope "/", KnitMakerWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{KnitMakerWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  # admin routes
  scope "/", KnitMakerWeb do
    pipe_through [:browser, :require_admin_user]

    live_session :require_admin_user,
      on_mount: [@ensure_authenticated],
      layout: {KnitMakerWeb.Layouts, :admin} do
      live "/events", EventLive.Index, :index
      live "/events/new", EventLive.Index, :new
      live "/events/:id", EventLive.Show, :show
      live "/events/:id/questions", EventLive.Show, :questions
      live "/events/:id/edit", EventLive.Show, :edit
      live "/events/:id/question/add", EventLive.Show, :add_question
      live "/events/:id/question/:question_id/edit", EventLive.Show, :edit_question
      live "/events/:id/question/:question_id/config", EventLive.Show, :config_question
      live "/events/:id/question/:question_id/visualize", EventLive.Show, :visualize_question

      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  # authenticated routes
  scope "/", KnitMakerWeb do
    pipe_through [:browser, :participant_session]

    live_session :participant do
      live "/:slug", MainLive, :start
      live "/:slug/q/:question_id", MainLive, :question
      live "/:slug/knitting", MainLive, :result
    end

    get "/image/event/:id", ImageController, :render
  end

  scope "/", KnitMakerWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{KnitMakerWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
