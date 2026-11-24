export type NavLink = {
  title: string;
  url: string;
  icon?: React.ComponentType;
  isActive?: boolean;
  items?: Array<NavLink>;
};

export type NavData = {
  user: {
    name: string;
    avatar: string;
  };
  main: NavLink[];
  secondary: NavLink[];
};
