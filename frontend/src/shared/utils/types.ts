export type NavLink = {
  title: string;
  url: string;
  icon?: React.ComponentType;
  isActive?: boolean;
  items?: Array<NavLink>;
  /** Hidden from everyone but admins. */
  adminOnly?: boolean;
};

export type NavData = {
  user: {
    name: string;
    avatar: string;
  };
  main: NavLink[];
  secondary: NavLink[];
};
